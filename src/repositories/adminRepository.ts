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

  constructor(private readonly db: Database) {
    this.achievementsTable = getSchemaQualifiedTable(db.schema, 'as_achievements');
    this.translationsTable = getSchemaQualifiedTable(db.schema, 'as_achievement_translations');
    this.eventListsTable = getSchemaQualifiedTable(db.schema, 'as_event_lists');
    this.userAchievementsTable = getSchemaQualifiedTable(db.schema, 'as_user_achievements');
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

  async listUserAchievements(query: AdminPageQuery): Promise<AdminPageResult<AdminUserAchievementRow>> {
    return this.listPage<AdminUserAchievementRow>({
      table: this.userAchievementsTable,
      select: 'id, userid, username, achievement_id, progress, achieved, achieved_at::text AS achieved_at',
      orderBy: 'updated_at DESC, id DESC',
      query,
    });
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
