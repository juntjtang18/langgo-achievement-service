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

    if (!userid || !eventName) {
      return { updated: 0 };
    }

    return this.db.withTransaction(async (client) => {
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

        updated += 1;
      }

      if (updated > 0) {
        this.logger.info({ userid, eventName, updated }, 'applied achievement event');
      }

      return { updated };
    });
  }
}
