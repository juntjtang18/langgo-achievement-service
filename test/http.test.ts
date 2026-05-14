import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';
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
      listAllEventNames: async () => ['flashcard.review'],
      listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listEventLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listAchievementChangeLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
    } as any,
    adminAuthService: {
      getLoginUrl: () => 'https://example.com/admin/auth/login',
      getSession: (sessionId?: string | null) => sessionId === 'valid-session'
        ? { id: 'valid-session', email: 'admin@example.com', strapiToken: 'token', roles: ['strapi-super-admin'] }
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
    expect(response.text).toContain('Only Strapi users with an admin role can access this UI.');
  });

  it('shows the non-admin hint when Strapi login is rejected by role enforcement', async () => {
    const app = createApp({
      achievementService: {
        ensureUserAchievements: async () => undefined,
        listAchievedByUserid: async () => [],
        listNotAchievedByUserid: async () => [],
      } as any,
      adminRepository: {
        listAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listTranslations: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listEventLists: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listAllEventNames: async () => ['flashcard.review'],
        listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      } as any,
      adminAuthService: {
        getLoginUrl: () => 'https://example.com/admin/auth/login',
        getSession: () => null,
        deleteSession: () => undefined,
        login: vi.fn(async () => {
          throw new Error('Only users with a Strapi admin role can sign in here.');
        }),
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

    const response = await request(app)
      .post('/admin/login')
      .type('form')
      .send({ email: 'user@example.com', password: 'secret' });

    expect(response.status).toBe(302);
    expect(response.headers.location).toContain('/admin/login');
    expect(response.headers.location).toContain('Only+users+with+a+Strapi+admin+role+can+sign+in+here.');
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
    expect(response.text).toContain('href="/admin/achievements/new"');
    expect(response.text).not.toContain('action="/admin/achievements/create"');
    expect(response.text).not.toContain('Manual Event Emit</h2>');
    expect(response.text).not.toContain('User Achievements</h2>');
  });

  it('renders the swagger api docs page for an authenticated admin session', async () => {
    const app = createTestApp();

    const response = await request(app)
      .get('/admin/api-docs')
      .set('Cookie', 'achievement_admin_session=valid-session');

    expect(response.status).toBe(200);
    expect(response.text).toContain('API Docs');
    expect(response.text).toContain('swagger-ui');
  });

  it('serves the swagger openapi document for an authenticated admin session', async () => {
    const app = createTestApp();

    const response = await request(app)
      .get('/admin/api-docs/openapi.json')
      .set('Cookie', 'achievement_admin_session=valid-session');

    expect(response.status).toBe(200);
    expect(response.body.openapi).toBe('3.0.3');
    expect(response.body.paths['/achievements-achieved']).toBeTruthy();
  });

  it('allows authenticated admin docs proxy requests without the internal key header', async () => {
    const app = createTestApp();

    const response = await request(app)
      .get('/admin/api-docs/proxy/achievements-not-achieved?locale=en')
      .set('Cookie', 'achievement_admin_session=valid-session')
      .set('x-user-id', '8');

    expect(response.status).toBe(200);
    expect(response.body.data).toHaveLength(1);
    expect(response.body.data[0].code).toBe('writer');
  });

  it('renders the event logs admin page with collapsed payload details', async () => {
    const app = createApp({
      achievementService: {
        ensureUserAchievements: async () => undefined,
        listAchievedByUserid: async () => [],
        listNotAchievedByUserid: async () => [],
      } as any,
      adminRepository: {
        listAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listTranslations: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listEventLists: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listAllEventNames: async () => ['flashcard.review'],
        listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listEventLogs: async () => ({
          rows: [{
            id: 1,
            event_name: 'flashcard.review',
            userid: '8',
            username: 'vivian',
            payload_json: '{"review":{"userId":8}}',
            received_at: '2026-05-10T22:00:00.000Z',
          }],
          total: 1,
          page: 1,
          pageSize: 20,
        }),
        listAchievementChangeLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      } as any,
      adminAuthService: {
        getLoginUrl: () => 'https://example.com/admin/auth/login',
        getSession: (sessionId?: string | null) => sessionId === 'valid-session'
          ? { id: 'valid-session', email: 'admin@example.com', strapiToken: 'token', roles: ['strapi-super-admin'] }
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

    const response = await request(app)
      .get('/admin/event-logs')
      .set('Cookie', 'achievement_admin_session=valid-session');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Event Logs');
    expect(response.text).toContain('<details>');
    expect(response.text).toContain('payload_json');
    expect(response.text).toContain('flashcard.review');
    expect(response.text).not.toContain('Manual Event Emit</h2>');
  });

  it('normalizes legacy manual event payloads into the canonical sibling event-bus format', async () => {
    const publishes: Array<{ topic: string; payload: any }> = [];
    const app = createApp({
      achievementService: {
        ensureUserAchievements: async () => undefined,
        listAchievedByUserid: async () => [],
        listNotAchievedByUserid: async () => [],
      } as any,
      adminRepository: {
        listAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listTranslations: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listEventLists: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listAllEventNames: async () => ['flashcard.review'],
        listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listEventLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
        listAchievementChangeLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      } as any,
      adminAuthService: {
        getLoginUrl: () => 'https://example.com/admin/auth/login',
        getSession: (sessionId?: string | null) => sessionId === 'valid-session'
          ? { id: 'valid-session', email: 'admin@example.com', strapiToken: 'token', roles: ['strapi-super-admin'] }
          : null,
        deleteSession: () => undefined,
        login: async () => {
          throw new Error('not implemented');
        },
      } as any,
      eventBus: {
        publish: async (topic: string, payload: any) => {
          publishes.push({ topic, payload });
          return { driver: 'postgres', topic, publishedAt: new Date().toISOString() };
        },
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

    const response = await request(app)
      .post('/admin/events/emit')
      .set('Cookie', 'achievement_admin_session=valid-session')
      .type('form')
      .send({
        topic: 'flashcard.review',
        payload_json: '{"userid":"8","username":"vivian"}',
      });

    expect(response.status).toBe(200);
    expect(publishes).toHaveLength(1);
    expect(publishes[0].topic).toBe('flashcard.review');
    expect(typeof publishes[0].payload.event_id).toBe('string');
    expect(publishes[0].payload.event_id.length).toBeGreaterThan(0);
    expect(publishes[0].payload.event_name).toBe('flashcard.review');
    expect(publishes[0].payload.userid).toBe('8');
    expect(publishes[0].payload.username).toBe('vivian');
  });
});
