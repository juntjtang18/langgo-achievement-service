import path from 'node:path';
import fs from 'node:fs/promises';
import dotenv from 'dotenv';
import request from 'supertest';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { createEventBus } from 'event-bus-client';
import { createApp } from '../src/app';
import { loadConfig } from '../src/config';
import { Database } from '../src/db';
import { createLogger } from '../src/logger';
import { AchievementRepository } from '../src/repositories/achievementRepository';
import { AchievementService } from '../src/services/achievementService';
import { EventHandlerService } from '../src/services/eventHandler';
import { EventSubscriberService } from '../src/services/eventSubscriberService';
import { ProgressService } from '../src/services/progressService';

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const hasIntegrationConfig = Boolean(
  process.env.DATABASE_HOST &&
  process.env.DATABASE_NAME &&
  process.env.DATABASE_USERNAME &&
  process.env.DATABASE_PASSWORD &&
  process.env.EVENT_BUS_POSTGRES_URL
);

const describeIfIntegration = hasIntegrationConfig ? describe : describe.skip;

function quoteIdentifier(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

async function waitFor<T>(
  check: () => Promise<T>,
  predicate: (value: T) => boolean,
  timeoutMs = 15000
): Promise<T> {
  const start = Date.now();

  while (Date.now() - start < timeoutMs) {
    const value = await check();
    if (predicate(value)) {
      return value;
    }

    await new Promise((resolve) => setTimeout(resolve, 200));
  }

  throw new Error(`Timed out after ${timeoutMs}ms`);
}

describeIfIntegration('achievement event bus integration', () => {
  const schema = `achievement_event_bus_test_${Date.now()}`;
  const channelPrefix = `achievementbus_${Date.now()}`;
  const env = {
    ...process.env,
    ACHIEVEMENT_INTERNAL_KEY: 'test-key',
    ACHIEVEMENT_DB_SCHEMA: schema,
    EVENT_BUS_CHANNEL_PREFIX: channelPrefix,
  };
  const config = loadConfig(env);
  const logger = createLogger('silent');
  const db = new Database(config, logger);
  const repository = new AchievementRepository(db);
  const achievementService = new AchievementService(repository);
  const progressService = new ProgressService(db, repository, logger);
  const eventHandler = new EventHandlerService(progressService);
  const eventBus = createEventBus({
    driver: 'postgres',
    config: {
      connectionString: process.env.EVENT_BUS_POSTGRES_URL ?? '',
      channelPrefix,
    },
    logger,
  });
  const subscriberService = new EventSubscriberService(repository, eventBus as any, eventHandler, logger);
  const app = createApp({
    achievementService,
    logger,
    internalKey: 'test-key',
    adminRepository: {
      listAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listTranslations: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listEventLists: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listAllEventNames: async () => [],
      listUserAchievements: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listEventLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
      listAchievementChangeLogs: async () => ({ rows: [], total: 0, page: 1, pageSize: 20 }),
    } as any,
    adminAuthService: {
      getLoginUrl: () => 'https://example.com/admin/auth/login',
      getSession: () => null,
      deleteSession: () => undefined,
      login: async () => {
        throw new Error('not implemented');
      },
    } as any,
    eventBus: eventBus as any,
    subscriberService,
  });

  beforeAll(async () => {
    const initSql = await fs.readFile(path.resolve(process.cwd(), 'sql/init.sql'), 'utf8');
    const schemaSql = initSql.replaceAll('{{SCHEMA}}', quoteIdentifier(schema));
    await db.query(`CREATE SCHEMA IF NOT EXISTS ${quoteIdentifier(schema)}`);
    await db.query(schemaSql);
    await subscriberService.register();
  }, 30000);

  afterAll(async () => {
    await subscriberService.close();
    await eventBus.close();
    await db.query(`DROP SCHEMA IF EXISTS "${schema}" CASCADE`);
    await db.close();
  }, 30000);

  beforeEach(async () => {
    await db.query(`TRUNCATE TABLE "${schema}"."as_achievement_change_logs", "${schema}"."as_event_logs", "${schema}"."as_user_achievements", "${schema}"."as_achievement_translations", "${schema}"."as_achievements", "${schema}"."as_event_lists" RESTART IDENTITY CASCADE`);

    await db.query(`
      INSERT INTO "${schema}"."as_event_lists" (id, event_name, points, created_at, updated_at)
      VALUES
        (1, 'flashcard.created', 1, NOW(), NOW()),
        (2, 'flashcard.reviewed', 2, NOW(), NOW()),
        (3, 'flashcard.remembered', 5, NOW(), NOW()),
        (4, 'article.created', 1, NOW(), NOW());

      INSERT INTO "${schema}"."as_achievements" (id, code, event_name, icon_name, points, goal, created_at, updated_at)
      VALUES
        (10, 'flashcard-created-1', 'flashcard.created', 'pencil', 1, 1, NOW(), NOW()),
        (11, 'flashcard-reviewed-2', 'flashcard.reviewed', 'checkmark.circle', 2, 4, NOW(), NOW()),
        (12, 'flashcard-remembered-1', 'flashcard.remembered', 'star.fill', 5, 5, NOW(), NOW()),
        (13, 'article-created-1', 'article.created', 'doc.text', 1, 1, NOW(), NOW());

      INSERT INTO "${schema}"."as_achievement_translations" (id, achievement_id, locale, title, description, created_at, updated_at)
      VALUES
        (20, 10, 'en', 'Create a Flashcard', 'Create your first flashcard', NOW(), NOW()),
        (21, 10, 'zh', '创建闪卡', '创建你的第一张闪卡', NOW(), NOW()),
        (22, 11, 'en', 'Review Twice', 'Complete two effective reviews', NOW(), NOW()),
        (23, 11, 'zh', '完成两次复习', '完成两次有效复习', NOW(), NOW()),
        (24, 12, 'en', 'Remember One', 'Remember your first flashcard', NOW(), NOW()),
        (25, 12, 'zh', '记住一张', '记住你的第一张闪卡', NOW(), NOW()),
        (26, 13, 'en', 'Write an Article', 'Create your first article', NOW(), NOW()),
        (27, 13, 'zh', '写一篇文章', '创建你的第一篇文章', NOW(), NOW());
    `);

    await subscriberService.refresh();
  });

  it('consumes canonical Strapi events and exposes achieved and not-achieved rows via HTTP', async () => {
    await eventBus.publish('flashcard.created', {
      eventId: 'flashcard.created:3001',
      eventType: 'flashcard.created',
      occurredAt: '2026-05-12T02:38:59.747Z',
      flashcardId: 3001,
      userId: 8,
      username: 'vivian',
    });

    await eventBus.publish('flashcard.reviewed', {
      eventId: 'flashcard.reviewed:3001:8:2026-05-12T02:38:59.747Z',
      eventType: 'flashcard.reviewed',
      occurredAt: '2026-05-12T02:38:59.747Z',
      flashcardId: 3001,
      userId: 8,
      username: 'vivian',
      result: 'correct',
      tierBefore: 'new',
      effective: true,
    });

    await eventBus.publish('flashcard.reviewed', {
      eventId: 'flashcard.reviewed:3001:8:2026-05-12T02:39:59.747Z',
      eventType: 'flashcard.reviewed',
      occurredAt: '2026-05-12T02:39:59.747Z',
      flashcardId: 3001,
      userId: 8,
      username: 'vivian',
      result: 'correct',
      tierBefore: 'warmup',
      effective: true,
    });

    await eventBus.publish('flashcard.remembered', {
      eventId: 'flashcard.remembered:3001:8',
      eventType: 'flashcard.remembered',
      occurredAt: '2026-05-12T02:40:59.747Z',
      flashcardId: 3001,
      userId: 8,
      username: 'vivian',
    });

    await eventBus.publish('article.created', {
      eventId: 'article.created:7001',
      eventType: 'article.created',
      occurredAt: '2026-05-12T02:41:59.747Z',
      articleId: 7001,
      userId: 8,
      username: 'vivian',
    });

    const achievements = await waitFor(
      () => repository.listUserAchievements('8'),
      (rows) => rows.length === 4 && rows.every((row) => row.achieved)
    );

    expect(achievements.map((row) => ({
      achievement_id: row.achievement_id,
      progress: row.progress,
      achieved: row.achieved,
    }))).toEqual([
      { achievement_id: 10, progress: 1, achieved: true },
      { achievement_id: 11, progress: 4, achieved: true },
      { achievement_id: 12, progress: 5, achieved: true },
      { achievement_id: 13, progress: 1, achieved: true },
    ]);

    const eventLogs = await waitFor(
      async () => db.query<{ count: string }>(`SELECT COUNT(*)::text AS count FROM "${schema}"."as_event_logs" WHERE userid = '8'`),
      (result) => Number(result.rows[0]?.count ?? '0') === 5
    );
    expect(Number(eventLogs.rows[0]?.count ?? '0')).toBe(5);

    const achievedResponse = await request(app)
      .get('/api/v1/achievements-achieved?locale=zh-Hans')
      .set('x-internal-key', 'test-key')
      .set('x-user-id', '8');

    expect(achievedResponse.status).toBe(200);
    expect(achievedResponse.body.data).toEqual([
      expect.objectContaining({ code: 'flashcard-created-1', title: '创建闪卡', achieved: true, progress: 1 }),
      expect.objectContaining({ code: 'flashcard-reviewed-2', title: '完成两次复习', achieved: true, progress: 4 }),
      expect.objectContaining({ code: 'flashcard-remembered-1', title: '记住一张', achieved: true, progress: 5 }),
      expect.objectContaining({ code: 'article-created-1', title: '写一篇文章', achieved: true, progress: 1 }),
    ]);

    const notAchievedResponse = await request(app)
      .get('/api/v1/achievements-not-achieved?locale=en')
      .set('x-internal-key', 'test-key')
      .set('x-user-id', '8');

    expect(notAchievedResponse.status).toBe(200);
    expect(notAchievedResponse.body).toEqual({ data: [] });
  }, 30000);
});
