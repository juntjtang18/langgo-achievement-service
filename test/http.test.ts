import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createLogger } from '../src/logger';
import { createApp } from '../src/app';

function createTestApp() {
  return createApp({
    achievementService: {
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
    adminRepository: {
      listAchievements: async () => [],
      listTranslations: async () => [],
      listEventLists: async () => [],
      listUserAchievements: async () => [],
    } as any,
    adminAuthService: {
      getLoginUrl: () => 'https://example.com/admin/auth/login',
      getSession: () => null,
      deleteSession: () => undefined,
      login: async () => {
        throw new Error('not implemented');
      },
    } as any,
    eventBus: {
      publish: async () => ({ driver: 'postgres', topic: 'x', publishedAt: new Date().toISOString() }),
      subscribe: async () => ({ topic: 'x', unsubscribe: async () => undefined }),
      close: async () => undefined,
    } as any,
    subscriberService: {
      refresh: async () => undefined,
      close: async () => undefined,
    } as any,
    logger: createLogger('silent'),
    internalKey: 'secret',
  });
}

describe('http routes', () => {
  it('rejects requests with missing internal key', async () => {
    const app = createTestApp();

    const response = await request(app)
      .get('/achievements-achieved')
      .set('x-user-id', '8');

    expect(response.status).toBe(401);
  });

  it('returns Strapi-compatible response shape', async () => {
    const app = createTestApp();

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

  it('serves the admin login page without internal key auth', async () => {
    const app = createTestApp();

    const response = await request(app).get('/admin/login');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Achievement Admin');
    expect(response.text).toContain('Strapi-backed auth');
  });
});
