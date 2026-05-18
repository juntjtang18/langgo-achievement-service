import type { PoolClient } from 'pg';
import { Database, getSchemaQualifiedTable } from '../db';
import { getAchievementEventNameAliases } from '../eventNames';
import type {
  AchievementChangeLogRow,
  AchievementDefinition,
  AchievementResponseRow,
  AchievementTranslation,
  EventLogRow,
  UserAchievementRow,
} from '../types';

interface AchievementRow {
  id: number;
  code: string;
  event_name: string;
  icon_name: string | null;
  points: number;
  goal: number;
}

interface TranslationRow {
  id: number;
  achievement_id: number;
  locale: string | null;
  title: string | null;
  description: string | null;
}

function getLocaleCandidates(locale = 'en'): string[] {
  return Array.from(
    new Set(
      [locale, locale.split('-')[0], 'en']
        .filter((value) => typeof value === 'string' && value.length > 0)
    )
  );
}

export class AchievementRepository {
  private readonly achievementsTable: string;
  private readonly translationsTable: string;
  private readonly eventListsTable: string;
  private readonly userAchievementsTable: string;
  private readonly eventLogsTable: string;
  private readonly changeLogsTable: string;

  constructor(private readonly db: Database) {
    this.achievementsTable = getSchemaQualifiedTable(db.schema, 'as_achievements');
    this.translationsTable = getSchemaQualifiedTable(db.schema, 'as_achievement_translations');
    this.eventListsTable = getSchemaQualifiedTable(db.schema, 'as_event_lists');
    this.userAchievementsTable = getSchemaQualifiedTable(db.schema, 'as_user_achievements');
    this.eventLogsTable = getSchemaQualifiedTable(db.schema, 'as_event_logs');
    this.changeLogsTable = getSchemaQualifiedTable(db.schema, 'as_achievement_change_logs');
  }

  async listAchievements(): Promise<AchievementDefinition[]> {
    const [achievementsResult, translationsResult] = await Promise.all([
      this.db.query<AchievementRow>(
        `SELECT id, code, event_name, icon_name, points, goal
         FROM ${this.achievementsTable}
         ORDER BY id ASC`
      ),
      this.db.query<TranslationRow>(
        `SELECT id, achievement_id, locale, title, description
         FROM ${this.translationsTable}
         ORDER BY achievement_id ASC, id ASC`
      ),
    ]);

    const translationsByAchievementId = new Map<number, AchievementTranslation[]>();
    for (const row of translationsResult.rows) {
      const translations = translationsByAchievementId.get(row.achievement_id) ?? [];
      translations.push({
        id: row.id,
        achievement_id: row.achievement_id,
        locale: row.locale || 'en',
        title: row.title,
        description: row.description,
      });
      translationsByAchievementId.set(row.achievement_id, translations);
    }

    return achievementsResult.rows.map((row) => ({
      ...row,
      translations: translationsByAchievementId.get(row.id) ?? [],
    }));
  }

  async listUserAchievements(userid: string): Promise<UserAchievementRow[]> {
    const result = await this.db.query<UserAchievementRow>(
      `SELECT id, userid, username, achievement_id, progress, achieved,
              achieved_at::text AS achieved_at
       FROM ${this.userAchievementsTable}
       WHERE userid = $1
       ORDER BY achievement_id ASC`,
      [userid]
    );

    return result.rows;
  }

  async listUserAchievementResponses(
    userid: string,
    locale: string,
    achieved: boolean
  ): Promise<AchievementResponseRow[]> {
    const result = await this.db.query<AchievementResponseRow>(
      `SELECT
         a.id,
         a.code,
         a.event_name,
         a.icon_name,
         a.points,
         a.goal,
         COALESCE(ua.progress, 0) AS progress,
         COALESCE(ua.achieved, FALSE) AS achieved,
         ua.achieved_at::text AS achieved_at,
         translation.title,
         translation.description
       FROM ${this.achievementsTable} a
       LEFT JOIN ${this.userAchievementsTable} ua
         ON ua.achievement_id = a.id
        AND ua.userid = $1
       LEFT JOIN LATERAL (
         SELECT t.title, t.description
         FROM ${this.translationsTable} t
         WHERE t.achievement_id = a.id
           AND t.locale = ANY($3::text[])
         ORDER BY array_position($3::text[], t.locale), t.id ASC
         LIMIT 1
       ) translation ON TRUE
       WHERE COALESCE(ua.achieved, FALSE) = $2
       ORDER BY a.id ASC`,
      [userid, achieved, getLocaleCandidates(locale)]
    );

    return result.rows;
  }

  async listEventNames(): Promise<string[]> {
    const result = await this.db.query<{ event_name: string | null }>(
      `SELECT event_name
       FROM ${this.eventListsTable}
       ORDER BY id ASC`
    );

    return Array.from(
      new Set(
        result.rows
          .map((row) => row.event_name?.trim())
          .flatMap((eventName) => getAchievementEventNameAliases(eventName))
          .filter((value): value is string => Boolean(value))
      )
    );
  }

  async ensureUserAchievements(userid: string, username: string | null, client: PoolClient): Promise<void> {
    await client.query(
      `INSERT INTO ${this.userAchievementsTable} (userid, username, achievement_id, progress, achieved, achieved_at)
       SELECT $1, $2, a.id, 0, FALSE, NULL
       FROM ${this.achievementsTable} a
       LEFT JOIN ${this.userAchievementsTable} ua
         ON ua.userid = $1
        AND ua.achievement_id = a.id
       WHERE ua.id IS NULL`,
      [userid, username]
    );
  }

  async ensureUserAchievementsOutsideTransaction(userid: string, username: string | null): Promise<void> {
    await this.db.query(
      `INSERT INTO ${this.userAchievementsTable} (userid, username, achievement_id, progress, achieved, achieved_at)
       SELECT $1, $2, a.id, 0, FALSE, NULL
       FROM ${this.achievementsTable} a
       LEFT JOIN ${this.userAchievementsTable} ua
         ON ua.userid = $1
        AND ua.achievement_id = a.id
       WHERE ua.id IS NULL`,
      [userid, username]
    );
  }

  async listAchievementProgressForEvent(
    userid: string,
    eventName: string,
    client: PoolClient
  ): Promise<Array<AchievementRow & UserAchievementRow>> {
    const result = await client.query<AchievementRow & UserAchievementRow>(
      `SELECT a.id, a.code, a.event_name, a.icon_name, a.points, a.goal,
              ua.id, ua.userid, ua.username, ua.achievement_id, ua.progress,
              ua.achieved, ua.achieved_at::text AS achieved_at
       FROM ${this.achievementsTable} a
       INNER JOIN ${this.userAchievementsTable} ua
         ON ua.achievement_id = a.id
       WHERE ua.userid = $1
         AND a.event_name = ANY($2::text[])
       ORDER BY a.id ASC
       FOR UPDATE OF ua`,
      [userid, getAchievementEventNameAliases(eventName)]
    );

    return result.rows;
  }

  async updateUserAchievement(
    userAchievementId: number,
    username: string | null,
    progress: number,
    achieved: boolean,
    achievedAt: string | null,
    client: PoolClient
  ): Promise<void> {
    await client.query(
      `UPDATE ${this.userAchievementsTable}
       SET username = COALESCE($2, username),
           progress = $3,
           achieved = $4,
           achieved_at = $5,
           updated_at = NOW()
       WHERE id = $1`,
      [userAchievementId, username, progress, achieved, achievedAt]
    );
  }

  async insertEventLog(
    input: Omit<EventLogRow, 'id' | 'received_at' | 'status' | 'handle_result' | 'handled_at'>
  ): Promise<number> {
    const result = await this.db.query<{ id: number }>(
      `INSERT INTO ${this.eventLogsTable} (event_name, userid, username, payload_json, status)
       VALUES ($1, $2, $3, $4::jsonb, 'processing')
       RETURNING id`,
      [input.event_name, input.userid, input.username, JSON.stringify(input.payload_json ?? {})]
    );

    return result.rows[0].id;
  }

  async markEventLogHandled(eventLogId: number, handleResult: unknown): Promise<void> {
    await this.db.query(
      `UPDATE ${this.eventLogsTable}
       SET status = 'handled',
           handled_at = NOW(),
           handle_result = $2::jsonb
       WHERE id = $1`,
      [eventLogId, JSON.stringify(handleResult ?? { ok: true })]
    );
  }

  async markEventLogFailed(eventLogId: number, handleResult: unknown): Promise<void> {
    await this.db.query(
      `UPDATE ${this.eventLogsTable}
       SET status = 'failed',
           handled_at = NOW(),
           handle_result = $2::jsonb
       WHERE id = $1`,
      [eventLogId, JSON.stringify(handleResult ?? { ok: false })]
    );
  }

  async insertAchievementChangeLog(
    input: Omit<AchievementChangeLogRow, 'id' | 'created_at'>,
    client: PoolClient
  ): Promise<void> {
    await client.query(
      `INSERT INTO ${this.changeLogsTable}
       (event_log_id, achievement_id, user_achievement_id, event_name, userid, username,
        points_added, progress_before, progress_after, achieved_before, achieved_after, achieved_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      [
        input.event_log_id,
        input.achievement_id,
        input.user_achievement_id,
        input.event_name,
        input.userid,
        input.username,
        input.points_added,
        input.progress_before,
        input.progress_after,
        input.achieved_before,
        input.achieved_after,
        input.achieved_at,
      ]
    );
  }
}
