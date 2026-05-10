import fs from 'node:fs/promises';
import path from 'node:path';
import { Pool, type PoolClient, type QueryResult, type QueryResultRow } from 'pg';
import type { Logger } from 'pino';
import type { AppConfig } from './config';

const REQUIRED_TABLES = [
  'as_achievements',
  'as_achievement_translations',
  'as_event_lists',
  'as_user_achievements',
] as const;

function quoteIdentifier(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

function replaceSchema(sql: string, schema: string): string {
  return sql.replaceAll('{{SCHEMA}}', quoteIdentifier(schema));
}

export class Database {
  readonly pool: Pool;

  constructor(
    private readonly config: AppConfig,
    private readonly logger: Logger
  ) {
    this.pool = new Pool({
      host: config.database.host,
      port: config.database.port,
      database: config.database.database,
      user: config.database.user,
      password: config.database.password,
      ssl: config.database.ssl ? { rejectUnauthorized: false } : false,
      max: 10,
      idleTimeoutMillis: 30000,
    });
  }

  get schema(): string {
    return this.config.schema;
  }

  async initialize(): Promise<void> {
    await this.query(`CREATE SCHEMA IF NOT EXISTS ${quoteIdentifier(this.schema)}`);

    const tablesPresent = await this.hasRequiredTables();
    if (!tablesPresent) {
      const restored = await this.restoreFromBackupIfPresent();
      if (!restored) {
        await this.applySqlFile(path.resolve(process.cwd(), 'sql/init.sql'));
      }
    }

    const valid = await this.hasRequiredTables();
    if (!valid) {
      throw new Error(`Database initialization failed for schema "${this.schema}".`);
    }
  }

  async connectClient(): Promise<PoolClient> {
    return this.pool.connect();
  }

  async query<T extends QueryResultRow = QueryResultRow>(text: string, values?: unknown[]): Promise<QueryResult<T>> {
    return this.pool.query<T>(text, values);
  }

  async withTransaction<T>(callback: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.connectClient();
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async close(): Promise<void> {
    await this.pool.end();
  }

  private async hasRequiredTables(): Promise<boolean> {
    const result = await this.query<{ table_name: string }>(
      `
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = $1
          AND table_name = ANY($2::text[])
      `,
      [this.schema, REQUIRED_TABLES]
    );

    return REQUIRED_TABLES.every((table) => result.rows.some((row) => row.table_name === table));
  }

  private async restoreFromBackupIfPresent(): Promise<boolean> {
    const backupDir = path.resolve(process.cwd(), 'backup');
    let files: string[];

    try {
      files = (await fs.readdir(backupDir))
        .filter((file) => file.endsWith('.sql'))
        .sort();
    } catch {
      return false;
    }

    if (files.length === 0) {
      return false;
    }

    this.logger.info({ schema: this.schema, files }, 'restoring achievement schema from backup SQL');
    for (const file of files) {
      await this.applySqlFile(path.join(backupDir, file));
    }
    return true;
  }

  private async applySqlFile(filePath: string): Promise<void> {
    const raw = await fs.readFile(filePath, 'utf8');
    const sql = replaceSchema(raw, this.schema);
    await this.query(sql);
  }
}

export function getSchemaQualifiedTable(schema: string, table: string): string {
  return `${quoteIdentifier(schema)}.${quoteIdentifier(table)}`;
}
