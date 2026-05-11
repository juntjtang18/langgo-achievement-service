import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createLogger } from '../src/logger';
import { createApp } from '../src/app';

describe('http routes', () => {
  it('rejects requests with missing internal key', async () => {
    const app = createApp(
      {
        ensureUserAchievements: async () => undefined,
        listAchievedByUserid: async () => [],
        listNotAchievedByUserid: async () => [],
      } as any,
      createLogger('silent'),
      'secret'
    );

    const response = await request(app)
      .get('/achievements-achieved')
      .set('x-user-id', '8');

    expect(response.status).toBe(401);
  });

  it('returns Strapi-compatible response shape', async () => {
    const app = createApp(
      {
        ensureUserAchievements: async () => undefined,
        listAchievedByUserid: async () => [],
        listNotAchievedByUserid: async () => [
          {
            id: 11,
            code: 'writer',
            event_name: 'article.create',
            icon_name: null,
            points: 1,
            goal: 1,
            progress: 0,
            achieved: false,
            achieved_at: null,
            title: 'Writer',
            description: 'Write an article',
          },
        ],
      } as any,
      createLogger('silent'),
      'secret'
    );

    const response = await request(app)
      .get('/achievements-not-achieved?locale=en')
      .set('x-internal-key', 'secret')
      .set('x-user-id', '8');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      data: [
        {
          id: 11,
          code: 'writer',
          event_name: 'article.create',
          icon_name: null,
          points: 1,
          goal: 1,
          progress: 0,
          achieved: false,
          achieved_at: null,
          title: 'Writer',
          description: 'Write an article',
        },
      ],
    });
  });
});
