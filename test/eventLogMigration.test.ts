import path from 'node:path';
import fs from 'node:fs/promises';
import dotenv from 'dotenv';
import { Pool } from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const hasDatabaseConfig = Boolean(
  process.env.DATABASE_HOST &&
  process.env.DATABASE_NAME &&
  process.env.DATABASE_USERNAME &&
  process.env.DATABASE_PASSWORD
);

const describeIfDatabase = hasDatabaseConfig ? describe : describe.skip;

function quoteIdentifier(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

function replaceSchema(sql: string, schema: string): string {
  return sql.replaceAll('{{SCHEMA}}', quoteIdentifier(schema));
}

describeIfDatabase('as_event_logs status migration', () => {
  const schema = `achievement_event_log_migration_test_${Date.now()}`;
  const pool = new Pool({
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT || '5432'),
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    ssl: ['1', 'true', 'yes', 'on'].includes(String(process.env.DATABASE_SSL || '').toLowerCase())
      ? { rejectUnauthorized: false }
      : false,
    max: 2,
  });

  beforeAll(async () => {
    await pool.query(`CREATE SCHEMA ${quoteIdentifier(schema)}`);
  });

  afterAll(async () => {
    await pool.query(`DROP SCHEMA IF EXISTS ${quoteIdentifier(schema)} CASCADE`);
    await pool.end();
  });

  it('preserves existing rows, backfills handled status, and enforces valid status values', async () => {
    await pool.query(`
      CREATE TABLE ${quoteIdentifier(schema)}.as_event_logs (
        id BIGSERIAL PRIMARY KEY,
        event_name VARCHAR(255) NOT NULL,
        userid VARCHAR(255),
        username VARCHAR(255),
        payload_json JSONB NOT NULL,
        received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const inserted = await pool.query<{ id: string }>(
      `INSERT INTO ${quoteIdentifier(schema)}.as_event_logs (
         event_name, userid, username, payload_json, received_at
       )
       VALUES ($1, $2, $3, $4::jsonb, $5::timestamptz)
       RETURNING id`,
      [
        'flashcard.reviewed',
        '58',
        'aug13',
        JSON.stringify({ eventId: 'legacy-event' }),
        '2026-05-18T00:00:00.000Z',
      ]
    );

    const migrationSql = await fs.readFile(
      path.resolve(process.cwd(), 'sql/migrations/20260518_as_event_logs_status.sql'),
      'utf8'
    );
    await pool.query(replaceSchema(migrationSql, schema));

    const migrated = await pool.query<{
      id: string;
      status: string;
      handled_at: string | null;
      handle_result: unknown | null;
    }>(
      `SELECT id::text, status, handled_at::text, handle_result
       FROM ${quoteIdentifier(schema)}.as_event_logs
       WHERE id = $1`,
      [inserted.rows[0].id]
    );

    expect(migrated.rows).toHaveLength(1);
    expect(migrated.rows[0].status).toBe('handled');
    expect(migrated.rows[0].handled_at).not.toBeNull();
    expect(migrated.rows[0].handle_result).toBeNull();

    const defaulted = await pool.query<{ status: string }>(
      `INSERT INTO ${quoteIdentifier(schema)}.as_event_logs (
         event_name, userid, username, payload_json
       )
       VALUES ($1, $2, $3, $4::jsonb)
       RETURNING status`,
      ['article.created', '58', 'aug13', JSON.stringify({ eventId: 'default-status-event' })]
    );

    expect(defaulted.rows[0].status).toBe('handled');

    await expect(
      pool.query(
        `INSERT INTO ${quoteIdentifier(schema)}.as_event_logs (
           event_name, userid, username, payload_json, status
         )
         VALUES ($1, $2, $3, $4::jsonb, $5)`,
        ['flashcard.created', '58', 'aug13', JSON.stringify({ eventId: 'invalid-status-event' }), 'bad-status']
      )
    ).rejects.toMatchObject({ code: '23514' });
  });
});
