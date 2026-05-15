export const CANONICAL_ACHIEVEMENT_EVENT_NAMES = [
  'flashcard.created',
  'flashcard.reviewed',
  'flashcard.remembered',
  'article.created',
] as const;

export function normalizeAchievementEventName(eventName: string | null | undefined): string {
  return eventName?.trim() ?? '';
}

export function getAchievementEventNameAliases(eventName: string | null | undefined): string[] {
  const canonical = normalizeAchievementEventName(eventName);
  if (!canonical) {
    return [];
  }

  return [canonical];
}
