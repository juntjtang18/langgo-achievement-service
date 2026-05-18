import { describe, expect, it } from 'vitest';
import { getAchievementEventNameAliases, normalizeAchievementEventName } from '../src/eventNames';
import { AchievementRepository } from '../src/repositories/achievementRepository';
import { AchievementService } from '../src/services/achievementService';
import { EventHandlerService } from '../src/services/eventHandler';
import { ProgressService } from '../src/services/progressService';

function reportCase(testCase: string, expected: unknown, actual: unknown) {
  const message = [
    `[case] ${testCase}`,
    `[expected] ${JSON.stringify(expected)}`,
    `[actual] ${JSON.stringify(actual)}`,
  ].join('\n');

  // Keep explicit case/expected/actual output visible in test runs.
  console.info(message);
}

function createAuditRepository() {
  let nextEventLogId = 1;
  const eventLogs: Array<{ id: number; event_name: string; userid: string | null; username: string | null; payload_json: unknown }> = [];
  const handledLogs: Array<{ eventLogId: number; result: unknown }> = [];
  const failedLogs: Array<{ eventLogId: number; result: unknown }> = [];

  return {
    eventLogs,
    handledLogs,
    failedLogs,
    repository: {
      insertEventLog: async (input: { event_name: string; userid: string | null; username: string | null; payload_json: unknown }) => {
        const id = nextEventLogId;
        nextEventLogId += 1;
        eventLogs.push({ id, ...input });
        return id;
      },
      markEventLogHandled: async (eventLogId: number, result: unknown) => {
        handledLogs.push({ eventLogId, result });
      },
      markEventLogFailed: async (eventLogId: number, result: unknown) => {
        failedLogs.push({ eventLogId, result });
      },
    },
  };
}

describe('achievement service', () => {
  it('uses canonical Strapi event names for achievement subscriptions and progress lookup', async () => {
    expect(normalizeAchievementEventName('flashcard.created')).toBe('flashcard.created');
    expect(normalizeAchievementEventName('flashcard.reviewed')).toBe('flashcard.reviewed');
    expect(normalizeAchievementEventName('article.created')).toBe('article.created');
    expect(getAchievementEventNameAliases('flashcard.reviewed')).toEqual([
      'flashcard.reviewed',
    ]);

    const queries: Array<{ text: string; values?: unknown[] }> = [];
    const repository = new AchievementRepository({
      schema: 'achievement_test',
      pool: {},
      query: async (text: string, values?: unknown[]) => {
        queries.push({ text, values });
        if (text.includes('FROM "achievement_test"."as_event_lists"')) {
          return {
            rows: [
              { event_name: 'flashcard.created' },
              { event_name: 'flashcard.reviewed' },
              { event_name: 'article.created' },
            ],
          };
        }
        return { rows: [] };
      },
    } as any);

    await expect(repository.listEventNames()).resolves.toEqual([
      'flashcard.created',
      'flashcard.reviewed',
      'article.created',
    ]);

    await repository.listAchievementProgressForEvent('60', 'flashcard.reviewed', {
      query: async (text: string, values?: unknown[]) => {
        queries.push({ text, values });
        return { rows: [] };
      },
    } as any);
    expect(queries.at(-1)?.values).toEqual(['60', ['flashcard.reviewed']]);
  });

  it('falls back from locale variant to base locale', async () => {
    const service = new AchievementService({
      ensureUserAchievements: async () => undefined,
      listAchievements: async () => [
        {
          id: 10,
          code: 'review-novice',
          event_name: 'flashcard.reviewed',
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
        event_name: 'flashcard.reviewed',
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

  it('extracts unified event fields and delegates to progress service', async () => {
    const calls: any[] = [];
    const audit = createAuditRepository();
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        calls.push(event);
        return { updated: 1 };
      },
    } as ProgressService, audit.repository as any);

    const result = await eventHandler.handle({
      topic: 'flashcard.reviewed',
      payload: {
        userId: 8,
        username: 'vivian',
        eventType: 'flashcard.reviewed',
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    expect(result).toEqual({ updated: 1 });
    expect(calls).toEqual([
      {
        event_name: 'flashcard.reviewed',
        userid: '8',
        username: 'vivian',
        payload: {
          userId: 8,
          username: 'vivian',
          eventType: 'flashcard.reviewed',
        },
        eventLogId: 1,
      },
    ]);
    expect(audit.handledLogs).toEqual([{ eventLogId: 1, result: { ok: true, updated: 1 } }]);
  });

  it('accepts only the unified event schema', async () => {
    const cases = [
      {
        testCase: 'top-level userId/username on flashcard.created',
        topic: 'flashcard.created',
        payload: {
          userId: 101,
          username: 'alpha',
          eventType: 'flashcard.created',
        },
        expected: {
          event_name: 'flashcard.created',
          userid: '101',
          username: 'alpha',
        },
      },
      {
        testCase: 'topic falls back when eventType is omitted',
        topic: 'flashcard.reviewed',
        payload: {
          userId: 102,
          username: 'bravo',
        },
        expected: {
          event_name: 'flashcard.reviewed',
          userid: '102',
          username: 'bravo',
        },
      },
    ];

    const actualCalls: Array<{ event_name: string; userid: string | null; username: string | null }> = [];
    const audit = createAuditRepository();
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        actualCalls.push({
          event_name: event.event_name,
          userid: event.userid,
          username: event.username,
        });
        return { updated: 1 };
      },
    } as ProgressService, audit.repository as any);

    for (const entry of cases) {
      await eventHandler.handle({
        topic: entry.topic,
        payload: entry.payload,
        ack: async () => undefined,
        nack: async () => undefined,
      });
    }

    for (let index = 0; index < cases.length; index += 1) {
      const entry = cases[index];
      const actual = actualCalls[index];
      reportCase(entry.testCase, entry.expected, actual);
      expect(actual).toEqual(entry.expected);
    }
  });

  it('accepts canonical userId/username fields while preserving canonical userid/username when both are present', async () => {
    const calls: any[] = [];
    const audit = createAuditRepository();
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        calls.push(event);
        return { updated: 1 };
      },
    } as ProgressService, audit.repository as any);

    await eventHandler.handle({
      topic: '',
      payload: {
        eventType: 'flashcard.reviewed',
        userid: 501,
        username: 'canonical-user',
        userId: 999,
        userName: 'ignored-user-name',
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    await eventHandler.handle({
      topic: 'flashcard.created',
      payload: {
        userId: 502,
        userName: 'legacy-user',
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    const expected = [
      {
        event_name: 'flashcard.reviewed',
        userid: '501',
        username: 'canonical-user',
      },
      {
        event_name: 'flashcard.created',
        userid: '502',
        username: 'legacy-user',
      },
    ];

    const actual = calls.map((event) => ({
      event_name: event.event_name,
      userid: event.userid,
      username: event.username,
    }));

    reportCase(
      'achievement handler accepts canonical Strapi event fields and user field aliases',
      expected,
      actual
    );
    expect(actual).toEqual(expected);
  });

  it('marks event logs handled on success and failed when progress transaction rolls back', async () => {
    const successAudit = createAuditRepository();
    const successHandler = new EventHandlerService({
      applyEvent: async (event) => ({ updated: event.eventLogId }),
    } as ProgressService, successAudit.repository as any);

    await expect(successHandler.handle({
      topic: 'flashcard.reviewed',
      payload: { userId: 58, username: 'aug13', eventType: 'flashcard.reviewed' },
      ack: async () => undefined,
      nack: async () => undefined,
    })).resolves.toEqual({ updated: 1 });

    expect(successAudit.eventLogs).toHaveLength(1);
    expect(successAudit.failedLogs).toEqual([]);
    expect(successAudit.handledLogs).toEqual([{ eventLogId: 1, result: { ok: true, updated: 1 } }]);

    const failedAudit = createAuditRepository();
    let rolledBack = false;
    const failedHandler = new EventHandlerService({
      applyEvent: async () => {
        rolledBack = true;
        throw new Error('forced progress failure');
      },
    } as unknown as ProgressService, failedAudit.repository as any);

    await expect(failedHandler.handle({
      topic: 'flashcard.reviewed',
      payload: { userId: 58, username: 'aug13', eventType: 'flashcard.reviewed' },
      ack: async () => undefined,
      nack: async () => undefined,
    })).rejects.toThrow('forced progress failure');

    expect(rolledBack).toBe(true);
    expect(failedAudit.eventLogs).toHaveLength(1);
    expect(failedAudit.handledLogs).toEqual([]);
    expect(failedAudit.failedLogs).toEqual([
      { eventLogId: 1, result: { ok: false, error: 'forced progress failure' } },
    ]);
  });

  it('applies progress increments for every supported achievement event type', async () => {
    const state = new Map<string, {
      id: number;
      userid: string;
      username: string | null;
      achievement_id: number;
      progress: number;
      achieved: boolean;
      achieved_at: string | null;
      points: number;
      goal: number;
      event_name: string;
    }>();

    const definitions = [
      { achievement_id: 1, event_name: 'flashcard.created', points: 1, goal: 2 },
      { achievement_id: 2, event_name: 'flashcard.reviewed', points: 2, goal: 5 },
      { achievement_id: 3, event_name: 'flashcard.remembered', points: 3, goal: 3 },
      { achievement_id: 4, event_name: 'article.created', points: 1, goal: 1 },
    ];
    const audit = createAuditRepository();
    const changeLogs: Array<{ event_log_id: number; achievement_id: number; points_added: number; progress_before: number; progress_after: number }> = [];

    const db = {
      withTransaction: async (callback: (client: unknown) => Promise<{ updated: number }>) => callback({}),
    } as any;

    const repository = {
      ensureUserAchievements: async (userid: string, username: string | null) => {
        for (const definition of definitions) {
          const key = `${userid}:${definition.achievement_id}`;
          if (!state.has(key)) {
            state.set(key, {
              id: definition.achievement_id,
              userid,
              username,
              achievement_id: definition.achievement_id,
              progress: 0,
              achieved: false,
              achieved_at: null,
              points: definition.points,
              goal: definition.goal,
              event_name: definition.event_name,
            });
          }
        }
      },
      listAchievementProgressForEvent: async (userid: string, eventName: string) =>
        Array.from(state.values())
          .filter((row) => row.userid === userid && row.event_name === eventName)
          .map((row) => ({ ...row })),
      updateUserAchievement: async (
        userAchievementId: number,
        username: string | null,
        progress: number,
        achieved: boolean,
        achievedAt: string | null
      ) => {
        for (const row of state.values()) {
          if (row.id === userAchievementId) {
            row.username = username ?? row.username;
            row.progress = progress;
            row.achieved = achieved;
            row.achieved_at = achievedAt;
          }
        }
      },
      insertAchievementChangeLog: async (input: {
        event_log_id: number;
        achievement_id: number;
        points_added: number;
        progress_before: number;
        progress_after: number;
      }) => {
        changeLogs.push(input);
      },
    } as any;

    const progressService = new ProgressService(db, repository, {
      info: () => undefined,
      error: () => undefined,
      warn: () => undefined,
      debug: () => undefined,
      fatal: () => undefined,
      trace: () => undefined,
      silent: () => undefined,
      level: 'silent',
    } as any);

    const eventHandler = new EventHandlerService(progressService, audit.repository as any);
    const cases = [
      {
        testCase: 'flashcard.created increments by 1 and stays unachieved below goal',
        message: {
          topic: 'flashcard.created',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.created' },
        },
        expected: { progress: 1, achieved: false },
      },
      {
        testCase: 'flashcard.reviewed increments by 2 and stays unachieved below goal',
        message: {
          topic: 'flashcard.reviewed',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.reviewed' },
        },
        expected: { progress: 2, achieved: false },
      },
      {
        testCase: 'flashcard.remembered increments by 3 and reaches goal',
        message: {
          topic: 'flashcard.remembered',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.remembered' },
        },
        expected: { progress: 3, achieved: true },
      },
      {
        testCase: 'article.created increments by 1 and reaches goal',
        message: {
          topic: 'article.created',
          payload: { userId: 200, username: 'iris', eventType: 'article.created' },
        },
        expected: { progress: 1, achieved: true },
      },
      {
        testCase: 'second flashcard.created reaches its goal on the second event',
        message: {
          topic: 'flashcard.created',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.created' },
        },
        expected: { progress: 2, achieved: true },
      },
      {
        testCase: 'second flashcard.reviewed accumulates to 4 and stays below goal',
        message: {
          topic: 'flashcard.reviewed',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.reviewed' },
        },
        expected: { progress: 4, achieved: false },
      },
      {
        testCase: 'third flashcard.reviewed accumulates to 6 and reaches goal',
        message: {
          topic: 'flashcard.reviewed',
          payload: { userId: 200, username: 'iris', eventType: 'flashcard.reviewed' },
        },
        expected: { progress: 6, achieved: true },
      },
    ];

    for (const entry of cases) {
      await eventHandler.handle({
        topic: entry.message.topic,
        payload: entry.message.payload,
        ack: async () => undefined,
        nack: async () => undefined,
      });

      const actualRow = Array.from(state.values()).find((row) => row.userid === '200' && row.event_name === entry.message.topic);
      const actual = {
        progress: actualRow?.progress ?? null,
        achieved: actualRow?.achieved ?? null,
      };

      reportCase(entry.testCase, entry.expected, actual);
      expect(actual).toEqual(entry.expected);
    }

    const auditActual = {
      eventLogs: audit.eventLogs.map((row) => ({ event_name: row.event_name, userid: row.userid })),
      changeLogs: changeLogs.map((row) => ({
        event_log_id: row.event_log_id,
        achievement_id: row.achievement_id,
        points_added: row.points_added,
        progress_before: row.progress_before,
        progress_after: row.progress_after,
      })),
    };
    const auditExpected = {
      eventLogs: [
        { event_name: 'flashcard.created', userid: '200' },
        { event_name: 'flashcard.reviewed', userid: '200' },
        { event_name: 'flashcard.remembered', userid: '200' },
        { event_name: 'article.created', userid: '200' },
        { event_name: 'flashcard.created', userid: '200' },
        { event_name: 'flashcard.reviewed', userid: '200' },
        { event_name: 'flashcard.reviewed', userid: '200' },
      ],
      changeLogs: [
        { event_log_id: 1, achievement_id: 1, points_added: 1, progress_before: 0, progress_after: 1 },
        { event_log_id: 2, achievement_id: 2, points_added: 2, progress_before: 0, progress_after: 2 },
        { event_log_id: 3, achievement_id: 3, points_added: 3, progress_before: 0, progress_after: 3 },
        { event_log_id: 4, achievement_id: 4, points_added: 1, progress_before: 0, progress_after: 1 },
        { event_log_id: 5, achievement_id: 1, points_added: 1, progress_before: 1, progress_after: 2 },
        { event_log_id: 6, achievement_id: 2, points_added: 2, progress_before: 2, progress_after: 4 },
        { event_log_id: 7, achievement_id: 2, points_added: 2, progress_before: 4, progress_after: 6 },
      ],
    };

    reportCase(
      'audit persistence writes one event log per received event and one change log per progress update',
      auditExpected,
      auditActual
    );
    expect(auditActual).toEqual(auditExpected);
    expect(audit.handledLogs.map((row) => row.eventLogId)).toEqual([1, 2, 3, 4, 5, 6, 7]);
  });
});
