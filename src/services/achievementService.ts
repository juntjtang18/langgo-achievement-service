import { AchievementRepository } from '../repositories/achievementRepository';
import type { AchievementDefinition, AchievementResponseRow, AchievementTranslation, UserAchievementRow } from '../types';

function getLocaleCandidates(locale = 'en'): string[] {
  return Array.from(
    new Set(
      [locale, locale.split('-')[0], 'en']
        .filter((value) => typeof value === 'string' && value.length > 0)
    )
  );
}

function findTranslation(translations: AchievementTranslation[], locale: string): AchievementTranslation | null {
  const candidates = getLocaleCandidates(locale);
  for (const candidate of candidates) {
    const match = translations.find((row) => (row.locale || 'en') === candidate);
    if (match) {
      return match;
    }
  }

  return translations[0] ?? null;
}

function formatAchievement(
  achievement: AchievementDefinition,
  userAchievement: UserAchievementRow | null,
  locale: string
): AchievementResponseRow {
  const translation = findTranslation(achievement.translations, locale);

  return {
    id: achievement.id,
    code: achievement.code,
    event_name: achievement.event_name,
    icon_name: achievement.icon_name,
    points: achievement.points || 0,
    goal: achievement.goal || 0,
    progress: userAchievement?.progress || 0,
    achieved: userAchievement?.achieved === true,
    achieved_at: userAchievement?.achieved_at || null,
    title: translation?.title || null,
    description: translation?.description || null,
  };
}

export class AchievementService {
  constructor(private readonly repository: AchievementRepository) {}

  async ensureUserAchievements(userid: string | number): Promise<void> {
    await this.repository.ensureUserAchievements(String(userid), null);
  }

  async listAchievedByUserid(userid: string | number, locale = 'en'): Promise<AchievementResponseRow[]> {
    return this.listByAchievementState(String(userid), locale, true);
  }

  async listNotAchievedByUserid(userid: string | number, locale = 'en'): Promise<AchievementResponseRow[]> {
    return this.listByAchievementState(String(userid), locale, false);
  }

  private async listByAchievementState(userid: string, locale: string, achieved: boolean): Promise<AchievementResponseRow[]> {
    const [achievements, userAchievements] = await Promise.all([
      this.repository.listAchievements(),
      this.repository.listUserAchievements(userid),
    ]);

    const userMap = new Map(userAchievements.map((row) => [row.achievement_id, row]));

    return achievements
      .map((achievement) => formatAchievement(achievement, userMap.get(achievement.id) ?? null, locale))
      .filter((row) => row.achieved === achieved);
  }
}
