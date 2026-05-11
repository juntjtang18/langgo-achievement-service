import { Database, getSchemaQualifiedTable } from '../db';

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

  async listAchievements(): Promise<AdminAchievementRow[]> {
    const result = await this.db.query<AdminAchievementRow>(
      `SELECT id, code, event_name, icon_name, points, goal
       FROM ${this.achievementsTable}
       ORDER BY id ASC`
    );
    return result.rows;
  }

  async listTranslations(): Promise<AdminTranslationRow[]> {
    const result = await this.db.query<AdminTranslationRow>(
      `SELECT id, achievement_id, locale, title, description
       FROM ${this.translationsTable}
       ORDER BY achievement_id ASC, locale ASC, id ASC`
    );
    return result.rows;
  }

  async listEventLists(): Promise<AdminEventListRow[]> {
    const result = await this.db.query<AdminEventListRow>(
      `SELECT id, event_name, points
       FROM ${this.eventListsTable}
       ORDER BY id ASC`
    );
    return result.rows;
  }

  async listUserAchievements(limit = 200): Promise<AdminUserAchievementRow[]> {
    const result = await this.db.query<AdminUserAchievementRow>(
      `SELECT id, userid, username, achievement_id, progress, achieved,
              achieved_at::text AS achieved_at
       FROM ${this.userAchievementsTable}
       ORDER BY updated_at DESC, id DESC
       LIMIT $1`,
      [limit]
    );
    return result.rows;
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
}
