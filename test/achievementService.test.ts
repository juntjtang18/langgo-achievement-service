import { describe, expect, it } from 'vitest';
import { AchievementService } from '../src/services/achievementService';
import { EventHandlerService } from '../src/services/eventHandler';
import { ProgressService } from '../src/services/progressService';

describe('achievement service', () => {
  it('falls back from locale variant to base locale', async () => {
    const service = new AchievementService({
      ensureUserAchievements: async () => undefined,
      listAchievements: async () => [
        {
          id: 10,
          code: 'review-novice',
          event_name: 'flashcard.review',
          icon_name: null,
          points: 2,
          goal: 5,
          translations: [
            { id: 1, achievement_id: 10, locale: 'zh', title: '复习新手', description: '去复习' },
            { id: 2, achievement_id: 10, locale: 'en', title: 'Review Novice', description: 'Do reviews' },
          ],
        },
      ],
      listUserAchievements: async () => [
        {
          id: 99,
          userid: '8',
          username: 'vivian',
          achievement_id: 10,
          progress: 6,
          achieved: true,
          achieved_at: '2026-05-04T21:00:00.000Z',
        },
      ],
    } as any);

    const rows = await service.listAchievedByUserid('8', 'zh-Hans');
    expect(rows).toEqual([
      {
        id: 10,
        code: 'review-novice',
        event_name: 'flashcard.review',
        icon_name: null,
        points: 2,
        goal: 5,
        progress: 6,
        achieved: true,
        achieved_at: '2026-05-04T21:00:00.000Z',
        title: '复习新手',
        description: '去复习',
      },
    ]);
  });

  it('extracts nested user data and delegates to progress service', async () => {
    const calls: any[] = [];
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        calls.push(event);
        return { updated: 1 };
      },
    } as ProgressService);

    const result = await eventHandler.handle({
      topic: 'flashcard.review',
      payload: {
        review: {
          userId: 8,
          userName: 'vivian',
        },
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    expect(result).toEqual({ updated: 1 });
    expect(calls).toEqual([
      {
        event_name: 'flashcard.review',
        userid: '8',
        username: 'vivian',
        payload: {
          review: {
            userId: 8,
            userName: 'vivian',
          },
        },
      },
    ]);
  });
});
