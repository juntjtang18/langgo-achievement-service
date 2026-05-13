import type { QueryResultRow } from 'pg';
import { Database, getSchemaQualifiedTable } from '../db';

export interface AdminPageQuery {
  page: number;
  pageSize: number;
  whereClause: string | null;
}

export interface AdminPageResult<TRow> {
  rows: TRow[];
  total: number;
  page: number;
  pageSize: number;
}

export interface AdminAchievementRow {
  id: number;
  code: string;
  event_name: string;
  icon_name: string | null;
  points: number;
  goal: number;
}

export interface AdminTranslationRow {
  id: number;
  achievement_id: number;
  locale: string;
  title: string | null;
  description: string | null;
}

export interface AdminEventListRow {
  id: number;
  event_name: string;
  points: number;
}

export interface AdminUserAchievementRow {
  id: number;
  userid: string;
  username: string | null;
  achievement_id: number;
  progress: number;
  achieved: boolean;
  achieved_at: string | null;
}

export interface AdminEventLogRow {
  id: number;
  event_name: string;
  userid: string | null;
  username: string | null;
  payload_json: string;
  received_at: string;
}

export interface AdminAchievementChangeLogRow {
  id: number;
  event_log_id: number;
  achievement_id: number;
  user_achievement_id: number;
  event_name: string;
  userid: string;
  username: string | null;
  points_added: number;
  progress_before: number;
  progress_after: number;
  achieved_before: boolean;
  achieved_after: boolean;
  achieved_at: string | null;
  created_at: string;
}

export interface AdminDashboardData {
  totals: {
    events: number;
    users: number;
    userAchievements: number;
    achievementDefinitions: number;
  };
  dailyEvents: Array<{ day: string; count: number }>;
  eventTypeCounts: Array<{ event_name: string; count: number }>;
  dailyPoints: Array<{ day: string; points: number }>;
  topUsers: Array<{ userid: string; username: string | null; count: number }>;
}

function sanitizeWhereClause(whereClause: string | null): string {
  if (!whereClause) {
    return '';
  }

  const trimmed = whereClause.trim();
  if (trimmed === '') {
    return '';
  }

  if (trimmed.includes(';') || trimmed.includes('--') || trimmed.includes('/*') || trimmed.includes('*/')) {
    throw new Error('Invalid where clause.');
  }

  return ` WHERE (${trimmed})`;
}

export class AdminRepository {
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

  async listAchievements(query: AdminPageQuery): Promise<AdminPageResult<AdminAchievementRow>> {
    return this.listPage<AdminAchievementRow>({
      table: this.achievementsTable,
      select: 'id, code, event_name, icon_name, points, goal',
      orderBy: 'id ASC',
      query,
    });
  }

  async listTranslations(query: AdminPageQuery): Promise<AdminPageResult<AdminTranslationRow>> {
    return this.listPage<AdminTranslationRow>({
      table: this.translationsTable,
      select: 'id, achievement_id, locale, title, description',
      orderBy: 'achievement_id ASC, locale ASC, id ASC',
      query,
    });
  }

  async listEventLists(query: AdminPageQuery): Promise<AdminPageResult<AdminEventListRow>> {
    return this.listPage<AdminEventListRow>({
      table: this.eventListsTable,
      select: 'id, event_name, points',
      orderBy: 'id ASC',
      query,
    });
  }

  async listAllEventNames(): Promise<string[]> {
    const result = await this.db.query<{ event_name: string }>(
      `SELECT event_name
       FROM ${this.eventListsTable}
       ORDER BY id ASC`
    );

    return result.rows
      .map((row) => row.event_name?.trim())
      .filter((value): value is string => Boolean(value));
  }

  async listUserAchievements(query: AdminPageQuery): Promise<AdminPageResult<AdminUserAchievementRow>> {
    return this.listPage<AdminUserAchievementRow>({
      table: this.userAchievementsTable,
      select: 'id, userid, username, achievement_id, progress, achieved, achieved_at::text AS achieved_at',
      orderBy: 'updated_at DESC, id DESC',
      query,
    });
  }

  async listEventLogs(query: AdminPageQuery): Promise<AdminPageResult<AdminEventLogRow>> {
    return this.listPage<AdminEventLogRow>({
      table: this.eventLogsTable,
      select: 'id, event_name, userid, username, payload_json::text AS payload_json, received_at::text AS received_at',
      orderBy: 'received_at DESC, id DESC',
      query,
    });
  }

  async listAchievementChangeLogs(query: AdminPageQuery): Promise<AdminPageResult<AdminAchievementChangeLogRow>> {
    return this.listPage<AdminAchievementChangeLogRow>({
      table: this.changeLogsTable,
      select: `id, event_log_id, achievement_id, user_achievement_id, event_name, userid, username,
               points_added, progress_before, progress_after, achieved_before, achieved_after,
               achieved_at::text AS achieved_at, created_at::text AS created_at`,
      orderBy: 'created_at DESC, id DESC',
      query,
    });
  }

  async getDashboardData(): Promise<AdminDashboardData> {
    const [totals, dailyEvents, eventTypeCounts, dailyPoints, topUsers] = await Promise.all([
      this.db.query<{
        events: string;
        users: string;
        user_achievements: string;
        achievement_definitions: string;
      }>(
        `SELECT
           (SELECT COUNT(*)::text FROM ${this.eventLogsTable}) AS events,
           (SELECT COUNT(DISTINCT userid)::text FROM ${this.eventLogsTable} WHERE userid IS NOT NULL AND userid <> '') AS users,
           (SELECT COUNT(*)::text FROM ${this.userAchievementsTable}) AS user_achievements,
           (SELECT COUNT(*)::text FROM ${this.achievementsTable}) AS achievement_definitions`
      ),
      this.db.query<{ day: string; count: string }>(
        `WITH days AS (
           SELECT generate_series(CURRENT_DATE - INTERVAL '119 days', CURRENT_DATE, INTERVAL '1 day')::date AS day
         ),
         event_counts AS (
           SELECT received_at::date AS day, COUNT(*)::text AS count
           FROM ${this.eventLogsTable}
           WHERE received_at >= CURRENT_DATE - INTERVAL '119 days'
           GROUP BY received_at::date
         )
         SELECT days.day::text AS day, COALESCE(event_counts.count, '0') AS count
         FROM days
         LEFT JOIN event_counts ON event_counts.day = days.day
         ORDER BY days.day ASC`
      ),
      this.db.query<{ event_name: string; count: string }>(
        `SELECT event_name, COUNT(*)::text AS count
         FROM ${this.eventLogsTable}
         WHERE received_at >= CURRENT_DATE - INTERVAL '119 days'
         GROUP BY event_name
         ORDER BY COUNT(*) DESC, event_name ASC`
      ),
      this.db.query<{ day: string; points: string }>(
        `WITH days AS (
           SELECT generate_series(CURRENT_DATE - INTERVAL '119 days', CURRENT_DATE, INTERVAL '1 day')::date AS day
         ),
         point_totals AS (
           SELECT created_at::date AS day, COALESCE(SUM(points_added), 0)::text AS points
           FROM ${this.changeLogsTable}
           WHERE created_at >= CURRENT_DATE - INTERVAL '119 days'
           GROUP BY created_at::date
         )
         SELECT days.day::text AS day, COALESCE(point_totals.points, '0') AS points
         FROM days
         LEFT JOIN point_totals ON point_totals.day = days.day
         ORDER BY days.day ASC`
      ),
      this.db.query<{ userid: string; username: string | null; count: string }>(
        `SELECT userid, MAX(username) AS username, COUNT(*)::text AS count
         FROM ${this.eventLogsTable}
         WHERE received_at >= CURRENT_DATE - INTERVAL '119 days'
           AND userid IS NOT NULL
           AND userid <> ''
         GROUP BY userid
         ORDER BY COUNT(*) DESC, userid ASC
         LIMIT 8`
      ),
    ]);

    return {
      totals: {
        events: Number(totals.rows[0]?.events ?? '0'),
        users: Number(totals.rows[0]?.users ?? '0'),
        userAchievements: Number(totals.rows[0]?.user_achievements ?? '0'),
        achievementDefinitions: Number(totals.rows[0]?.achievement_definitions ?? '0'),
      },
      dailyEvents: dailyEvents.rows.map((row) => ({ day: row.day, count: Number(row.count) })),
      eventTypeCounts: eventTypeCounts.rows.map((row) => ({ event_name: row.event_name, count: Number(row.count) })),
      dailyPoints: dailyPoints.rows.map((row) => ({ day: row.day, points: Number(row.points) })),
      topUsers: topUsers.rows.map((row) => ({ userid: row.userid, username: row.username, count: Number(row.count) })),
    };
  }

  async createAchievement(input: Omit<AdminAchievementRow, 'id'>): Promise<void> {
    await this.db.query(
      `INSERT INTO ${this.achievementsTable} (code, event_name, icon_name, points, goal)
       VALUES ($1, $2, $3, $4, $5)`,
      [input.code, input.event_name, input.icon_name, input.points, input.goal]
    );
  }

  async updateAchievement(id: number, input: Omit<AdminAchievementRow, 'id'>): Promise<void> {
    await this.db.query(
      `UPDATE ${this.achievementsTable}
       SET code = $2,
           event_name = $3,
           icon_name = $4,
           points = $5,
           goal = $6,
           updated_at = NOW()
       WHERE id = $1`,
      [id, input.code, input.event_name, input.icon_name, input.points, input.goal]
    );
  }

  async deleteAchievement(id: number): Promise<void> {
    await this.db.query(`DELETE FROM ${this.achievementsTable} WHERE id = $1`, [id]);
  }

  async createTranslation(input: Omit<AdminTranslationRow, 'id'>): Promise<void> {
    await this.db.query(
      `INSERT INTO ${this.translationsTable} (achievement_id, locale, title, description)
       VALUES ($1, $2, $3, $4)`,
      [input.achievement_id, input.locale, input.title, input.description]
    );
  }

  async updateTranslation(id: number, input: Omit<AdminTranslationRow, 'id'>): Promise<void> {
    await this.db.query(
      `UPDATE ${this.translationsTable}
       SET achievement_id = $2,
           locale = $3,
           title = $4,
           description = $5,
           updated_at = NOW()
       WHERE id = $1`,
      [id, input.achievement_id, input.locale, input.title, input.description]
    );
  }

  async deleteTranslation(id: number): Promise<void> {
    await this.db.query(`DELETE FROM ${this.translationsTable} WHERE id = $1`, [id]);
  }

  async createEventList(input: Omit<AdminEventListRow, 'id'>): Promise<void> {
    await this.db.query(
      `INSERT INTO ${this.eventListsTable} (event_name, points)
       VALUES ($1, $2)`,
      [input.event_name, input.points]
    );
  }

  async updateEventList(id: number, input: Omit<AdminEventListRow, 'id'>): Promise<void> {
    await this.db.query(
      `UPDATE ${this.eventListsTable}
       SET event_name = $2,
           points = $3,
           updated_at = NOW()
       WHERE id = $1`,
      [id, input.event_name, input.points]
    );
  }

  async deleteEventList(id: number): Promise<void> {
    await this.db.query(`DELETE FROM ${this.eventListsTable} WHERE id = $1`, [id]);
  }

  async updateUserAchievement(id: number, input: Omit<AdminUserAchievementRow, 'id'>): Promise<void> {
    await this.db.query(
      `UPDATE ${this.userAchievementsTable}
       SET userid = $2,
           username = $3,
           achievement_id = $4,
           progress = $5,
           achieved = $6,
           achieved_at = $7,
           updated_at = NOW()
       WHERE id = $1`,
      [id, input.userid, input.username, input.achievement_id, input.progress, input.achieved, input.achieved_at]
    );
  }

  async deleteUserAchievement(id: number): Promise<void> {
    await this.db.query(`DELETE FROM ${this.userAchievementsTable} WHERE id = $1`, [id]);
  }

  private async listPage<TRow extends QueryResultRow>(options: {
    table: string;
    select: string;
    orderBy: string;
    query: AdminPageQuery;
  }): Promise<AdminPageResult<TRow>> {
    const page = Math.max(1, options.query.page);
    const pageSize = Math.min(100, Math.max(1, options.query.pageSize));
    const offset = (page - 1) * pageSize;
    const whereSql = sanitizeWhereClause(options.query.whereClause);

    const [rowsResult, countResult] = await Promise.all([
      this.db.query<TRow>(
        `SELECT ${options.select}
         FROM ${options.table}${whereSql}
         ORDER BY ${options.orderBy}
         LIMIT $1 OFFSET $2`,
        [pageSize, offset]
      ),
      this.db.query<{ count: string }>(
        `SELECT COUNT(*)::text AS count
         FROM ${options.table}${whereSql}`
      ),
    ]);

    return {
      rows: rowsResult.rows,
      total: Number(countResult.rows[0]?.count ?? '0'),
      page,
      pageSize,
    };
  }
}
