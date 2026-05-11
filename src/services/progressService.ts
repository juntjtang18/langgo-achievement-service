import type { Logger } from 'pino';
import { Database } from '../db';
import { AchievementRepository } from '../repositories/achievementRepository';
import type { AchievementEvent } from '../types';

export class ProgressService {
  constructor(
    private readonly db: Database,
    private readonly repository: AchievementRepository,
    private readonly logger: Logger
  ) {}

  async applyEvent(event: AchievementEvent): Promise<{ updated: number }> {
    const userid = event.userid == null ? null : String(event.userid);
    const username = event.username || null;
    const eventName = event.event_name;

    return this.db.withTransaction(async (client) => {
      const eventLogId = await this.repository.insertEventLog({
        event_name: eventName,
        userid,
        username,
        payload_json: event.payload ?? {},
      }, client);

      if (!userid || !eventName) {
        return { updated: 0 };
      }

      await this.repository.ensureUserAchievements(userid, username, client);
      const rows = await this.repository.listAchievementProgressForEvent(userid, eventName, client);

      if (rows.length === 0) {
        return { updated: 0 };
      }

      let updated = 0;

      for (const row of rows) {
        if (row.achieved) {
          continue;
        }

        const previousProgress = row.progress || 0;
        const previousAchieved = Boolean(row.achieved);
        const nextProgress = (row.progress || 0) + (row.points || 0);
        const achieved = nextProgress >= (row.goal || 0);
        const achievedAt = achieved ? (row.achieved_at || new Date().toISOString()) : null;

        await this.repository.updateUserAchievement(
          row.id,
          username,
          nextProgress,
          achieved,
          achievedAt,
          client
        );

        await this.repository.insertAchievementChangeLog({
          event_log_id: eventLogId,
          achievement_id: row.achievement_id,
          user_achievement_id: row.id,
          event_name: eventName,
          userid,
          username,
          points_added: row.points || 0,
          progress_before: previousProgress,
          progress_after: nextProgress,
          achieved_before: previousAchieved,
          achieved_after: achieved,
          achieved_at: achievedAt,
        }, client);

        updated += 1;
      }

      if (updated > 0) {
        this.logger.info({ userid, eventName, updated }, 'applied achievement event');
      }

      return { updated };
    });
  }
}
