import { describe, expect, it } from 'vitest';
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

  it('extracts unified event fields and delegates to progress service', async () => {
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
        userid: 8,
        username: 'vivian',
        event_name: 'flashcard.review',
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
          userid: 8,
          username: 'vivian',
          event_name: 'flashcard.review',
        },
      },
    ]);
  });

  it('accepts only the unified event schema', async () => {
    const cases = [
      {
        testCase: 'top-level userid/username on flashcard.create',
        topic: 'flashcard.create',
        payload: {
          userid: 101,
          username: 'alpha',
          event_name: 'flashcard.create',
        },
        expected: {
          event_name: 'flashcard.create',
          userid: '101',
          username: 'alpha',
        },
      },
      {
        testCase: 'topic falls back when event_name is omitted',
        topic: 'flashcard.review',
        payload: {
          userid: 102,
          username: 'bravo',
        },
        expected: {
          event_name: 'flashcard.review',
          userid: '102',
          username: 'bravo',
        },
      },
    ];

    const actualCalls: Array<{ event_name: string; userid: string | null; username: string | null }> = [];
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        actualCalls.push({
          event_name: event.event_name,
          userid: event.userid,
          username: event.username,
        });
        return { updated: 1 };
      },
    } as ProgressService);

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

  it('ignores legacy alias fields that are outside the unified schema', async () => {
    const calls: any[] = [];
    const eventHandler = new EventHandlerService({
      applyEvent: async (event) => {
        calls.push(event);
        return { updated: 1 };
      },
    } as ProgressService);

    await eventHandler.handle({
      topic: '',
      payload: {
        event_name: 'flashcard.review',
        userid: 501,
        username: 'canonical-user',
        userId: 999,
        userName: 'ignored-user-name',
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    await eventHandler.handle({
      topic: 'flashcard.create',
      payload: {
        userId: 502,
        userName: 'legacy-user',
      },
      ack: async () => undefined,
      nack: async () => undefined,
    });

    const expected = [
      {
        event_name: 'flashcard.review',
        userid: '501',
        username: 'canonical-user',
      },
      {
        event_name: 'flashcard.create',
        userid: null,
        username: null,
      },
    ];

    const actual = calls.map((event) => ({
      event_name: event.event_name,
      userid: event.userid,
      username: event.username,
    }));

    reportCase(
      'achievement handler only reads userid, username, and event_name',
      expected,
      actual
    );
    expect(actual).toEqual(expected);
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
      { achievement_id: 1, event_name: 'flashcard.create', points: 1, goal: 2 },
      { achievement_id: 2, event_name: 'flashcard.review', points: 2, goal: 5 },
      { achievement_id: 3, event_name: 'flashcard.remembered', points: 3, goal: 3 },
      { achievement_id: 4, event_name: 'article.create', points: 1, goal: 1 },
    ];
    const eventLogs: Array<{ id: number; event_name: string; userid: string | null; username: string | null; payload_json: unknown }> = [];
    const changeLogs: Array<{ event_log_id: number; achievement_id: number; points_added: number; progress_before: number; progress_after: number }> = [];
    let nextEventLogId = 1;

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
      insertEventLog: async (input: { event_name: string; userid: string | null; username: string | null; payload_json: unknown }) => {
        eventLogs.push({ id: nextEventLogId, ...input });
        nextEventLogId += 1;
        return nextEventLogId - 1;
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

    const eventHandler = new EventHandlerService(progressService);
    const cases = [
      {
        testCase: 'flashcard.create increments by 1 and stays unachieved below goal',
        message: {
          topic: 'flashcard.create',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.create' },
        },
        expected: { progress: 1, achieved: false },
      },
      {
        testCase: 'flashcard.review increments by 2 and stays unachieved below goal',
        message: {
          topic: 'flashcard.review',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.review' },
        },
        expected: { progress: 2, achieved: false },
      },
      {
        testCase: 'flashcard.remembered increments by 3 and reaches goal',
        message: {
          topic: 'flashcard.remembered',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.remembered' },
        },
        expected: { progress: 3, achieved: true },
      },
      {
        testCase: 'article.create increments by 1 and reaches goal',
        message: {
          topic: 'article.create',
          payload: { userid: 200, username: 'iris', event_name: 'article.create' },
        },
        expected: { progress: 1, achieved: true },
      },
      {
        testCase: 'second flashcard.create reaches its goal on the second event',
        message: {
          topic: 'flashcard.create',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.create' },
        },
        expected: { progress: 2, achieved: true },
      },
      {
        testCase: 'second flashcard.review accumulates to 4 and stays below goal',
        message: {
          topic: 'flashcard.review',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.review' },
        },
        expected: { progress: 4, achieved: false },
      },
      {
        testCase: 'third flashcard.review accumulates to 6 and reaches goal',
        message: {
          topic: 'flashcard.review',
          payload: { userid: 200, username: 'iris', event_name: 'flashcard.review' },
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
      eventLogs: eventLogs.map((row) => ({ event_name: row.event_name, userid: row.userid })),
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
        { event_name: 'flashcard.create', userid: '200' },
        { event_name: 'flashcard.review', userid: '200' },
        { event_name: 'flashcard.remembered', userid: '200' },
        { event_name: 'article.create', userid: '200' },
        { event_name: 'flashcard.create', userid: '200' },
        { event_name: 'flashcard.review', userid: '200' },
        { event_name: 'flashcard.review', userid: '200' },
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
  });
});
