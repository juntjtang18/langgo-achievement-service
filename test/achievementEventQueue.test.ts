import { describe, expect, it, vi } from 'vitest';
import { AchievementEventQueue } from '../src/services/achievementEventQueue';
import { EventSubscriberService } from '../src/services/eventSubscriberService';

function deferred<T = void>() {
  let resolve!: (value: T | PromiseLike<T>) => void;
  let reject!: (reason?: unknown) => void;
  const promise = new Promise<T>((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

async function tick(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
}

describe('AchievementEventQueue', () => {
  it('serializes burst events for the same user', async () => {
    const queue = new AchievementEventQueue(3);
    let runningForUser = 0;
    let maxRunningForUser = 0;
    const executionOrder: number[] = [];

    await Promise.all(
      Array.from({ length: 8 }, (_, index) => queue.enqueue('58', async () => {
        runningForUser += 1;
        maxRunningForUser = Math.max(maxRunningForUser, runningForUser);
        executionOrder.push(index);
        await new Promise((resolve) => setTimeout(resolve, 5));
        runningForUser -= 1;
      }))
    );

    expect(maxRunningForUser).toBe(1);
    expect(executionOrder).toEqual([0, 1, 2, 3, 4, 5, 6, 7]);
  });

  it('runs different users in parallel up to configured concurrency', async () => {
    const queue = new AchievementEventQueue(2);
    let active = 0;
    let maxActive = 0;
    const blockers = [deferred(), deferred(), deferred(), deferred()];

    const tasks = blockers.map((blocker, index) => queue.enqueue(`user-${index}`, async () => {
      active += 1;
      maxActive = Math.max(maxActive, active);
      await blocker.promise;
      active -= 1;
    }));

    await tick();
    expect(queue.active).toBe(2);
    expect(maxActive).toBe(2);

    blockers[0].resolve();
    await tick();
    expect(queue.active).toBe(2);
    expect(maxActive).toBe(2);

    blockers.slice(1).forEach((blocker) => blocker.resolve());
    await Promise.all(tasks);
    expect(maxActive).toBe(2);
  });

  it('rejects failed tasks and continues processing later events', async () => {
    const queue = new AchievementEventQueue(1);
    const handled: string[] = [];

    await expect(queue.enqueue('58', async () => {
      handled.push('failed');
      throw new Error('handler failed');
    })).rejects.toThrow('handler failed');

    await queue.enqueue('58', async () => {
      handled.push('after-failure');
    });

    expect(handled).toEqual(['failed', 'after-failure']);
  });

  it('serializes missing-user events on the fallback key', async () => {
    const queue = new AchievementEventQueue(3);
    let active = 0;
    let maxActive = 0;

    await Promise.all(
      [null, undefined, ''].map((key) => queue.enqueue(key, async () => {
        active += 1;
        maxActive = Math.max(maxActive, active);
        await new Promise((resolve) => setTimeout(resolve, 5));
        active -= 1;
      }))
    );

    expect(maxActive).toBe(1);
  });

  it('rejects new tasks when the pending queue reaches the configured limit', async () => {
    const queue = new AchievementEventQueue(1, 2);
    const blocker = deferred();

    const first = queue.enqueue('active', async () => {
      await blocker.promise;
    });
    const second = queue.enqueue('pending-1', async () => undefined);
    const third = queue.enqueue('pending-2', async () => undefined);

    await tick();
    expect(queue.active).toBe(1);
    expect(queue.size).toBe(2);

    await expect(queue.enqueue('overflow', async () => undefined)).rejects.toThrow('AchievementEventQueue full');

    blocker.resolve();
    await Promise.all([first, second, third]);
  });
});

describe('EventSubscriberService queue integration', () => {
  it('keys flashcard.reviewed events by data.userId before payload.userId fallback', async () => {
    const handlers = new Map<string, (message: any) => Promise<void> | void>();
    const eventBus = {
      subscribe: vi.fn(async (topic: string, handler: (message: any) => Promise<void> | void) => {
        handlers.set(topic, handler);
        return { topic, unsubscribe: async () => undefined };
      }),
    };
    const blockers = [deferred(), deferred()];
    const startedUsers: number[] = [];
    let active = 0;
    let maxActive = 0;
    const eventHandler = {
      handle: vi.fn(async (message: any) => {
        startedUsers.push(message.payload.data.userId);
        active += 1;
        maxActive = Math.max(maxActive, active);
        await blockers[startedUsers.length - 1].promise;
        active -= 1;
        return { updated: 1 };
      }),
    };
    const subscriber = new EventSubscriberService(
      { listEventNames: async () => ['flashcard.reviewed'] } as any,
      eventBus as any,
      eventHandler as any,
      new AchievementEventQueue(2),
      {
        info: vi.fn(),
        error: vi.fn(),
      } as any
    );

    await subscriber.register();
    const handler = handlers.get('flashcard.reviewed');
    expect(handler).toBeDefined();

    const first = handler?.({
      topic: 'flashcard.reviewed',
      payload: { data: { userId: 58 }, eventType: 'flashcard.reviewed' },
      ack: vi.fn(async () => undefined),
      nack: vi.fn(async () => undefined),
    });
    const second = handler?.({
      topic: 'flashcard.reviewed',
      payload: { data: { userId: 60 }, eventType: 'flashcard.reviewed' },
      ack: vi.fn(async () => undefined),
      nack: vi.fn(async () => undefined),
    });

    await tick();
    expect(startedUsers).toEqual([58, 60]);
    expect(maxActive).toBe(2);

    blockers.forEach((blocker) => blocker.resolve());
    await Promise.all([first, second]);
  });

  it('acks only after queued handler success and nacks when the queued handler rejects', async () => {
    const handlers = new Map<string, (message: any) => Promise<void> | void>();
    const eventBus = {
      subscribe: vi.fn(async (topic: string, handler: (message: any) => Promise<void> | void) => {
        handlers.set(topic, handler);
        return { topic, unsubscribe: async () => undefined };
      }),
    };
    const eventHandler = {
      handle: vi.fn(async (message: any) => {
        if (message.payload.shouldFail) {
          throw new Error('boom');
        }
        return { updated: 1 };
      }),
    };
    const subscriber = new EventSubscriberService(
      { listEventNames: async () => ['flashcard.reviewed'] } as any,
      eventBus as any,
      eventHandler as any,
      new AchievementEventQueue(1),
      {
        info: vi.fn(),
        error: vi.fn(),
      } as any
    );

    await subscriber.register();
    const handler = handlers.get('flashcard.reviewed');
    expect(handler).toBeDefined();

    const successAck = vi.fn(async () => undefined);
    const successNack = vi.fn(async () => undefined);
    await handler?.({
      topic: 'flashcard.reviewed',
      payload: { userId: 58 },
      ack: successAck,
      nack: successNack,
    });

    expect(successAck).toHaveBeenCalledTimes(1);
    expect(successNack).not.toHaveBeenCalled();

    const failureAck = vi.fn(async () => undefined);
    const failureNack = vi.fn(async () => undefined);
    await handler?.({
      topic: 'flashcard.reviewed',
      payload: { userId: 58, shouldFail: true },
      ack: failureAck,
      nack: failureNack,
    });

    expect(failureAck).not.toHaveBeenCalled();
    expect(failureNack).toHaveBeenCalledTimes(1);

    const afterFailureAck = vi.fn(async () => undefined);
    const afterFailureNack = vi.fn(async () => undefined);
    await handler?.({
      topic: 'flashcard.reviewed',
      payload: { userId: 58 },
      ack: afterFailureAck,
      nack: afterFailureNack,
    });

    expect(afterFailureAck).toHaveBeenCalledTimes(1);
    expect(afterFailureNack).not.toHaveBeenCalled();
  });
});
