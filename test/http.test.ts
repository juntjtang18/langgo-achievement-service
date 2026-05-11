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
      listAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listTranslations: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listEventLists: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
    } as any,
    adminAuthService: {
      getLoginUrl: () => 'https://example.com/admin/auth/login',
      getSession: (sessionId?: string | null) => sessionId === 'valid-session'
        ? { id: 'valid-session', email: 'admin@example.com', strapiToken: 'token' }
        : null,
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

  it('renders only the selected admin section content', async () => {
    const app = createTestApp();

    const response = await request(app)
      .get('/admin/achievements?page=2&pageSize=10&where=points%20%3E%3D%201')
      .set('Cookie', 'achievement_admin_session=valid-session');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Achievements');
    expect(response.text).toContain('name="where"');
    expect(response.text).toContain('name="pageSize"');
    expect(response.text).toContain('points &gt;= 1');
    expect(response.text).not.toContain('Manual Event Emit</h2>');
    expect(response.text).not.toContain('User Achievements</h2>');
  });
});
