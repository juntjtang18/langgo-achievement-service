import type { Logger } from 'pino';
import { AchievementRepository } from '../repositories/achievementRepository';
import type { EventBus, EventBusSubscriptionHandle } from '../types';
import { AchievementEventQueue } from './achievementEventQueue';
import { EventHandlerService } from './eventHandler';

function getQueueKey(payload: Record<string, any> | null | undefined): string {
  const userId = payload?.data?.userId ?? payload?.userId;
  return userId == null || userId === '' ? '__unknown__' : String(userId);
}

export class EventSubscriberService {
  private subscriptions: EventBusSubscriptionHandle[] = [];

  constructor(
    private readonly repository: AchievementRepository,
    private readonly eventBus: EventBus,
    private readonly eventHandler: EventHandlerService,
    private readonly eventQueue: AchievementEventQueue,
    private readonly logger: Logger
  ) {}

  async register(): Promise<void> {
    await this.unregister();

    const eventNames = await this.repository.listEventNames();

    for (const eventName of eventNames) {
      this.logger.info({ eventName }, 'Subscribing to achievement event');
      const handle = await this.eventBus.subscribe<Record<string, any>>(eventName, async (message) => {
        try {
          this.logger.info({ eventName }, 'handling achievement event');
          await this.eventQueue.enqueue(getQueueKey(message.payload), () => this.eventHandler.handle(message));
          await message.ack();
        } catch (error) {
          this.logger.error({ err: error, eventName }, 'achievement event handler failed');
          await message.nack();
        }
      });

      this.subscriptions.push(handle);
    }
  }

  async refresh(): Promise<void> {
    await this.register();
  }

  private async unregister(): Promise<void> {
    const subscriptions = this.subscriptions;
    this.subscriptions = [];

    for (const handle of subscriptions) {
      this.logger.info({ eventName: handle.topic }, 'Unsubscribing from achievement event');
      await handle.unsubscribe();
    }
  }

  async close(): Promise<void> {
    await this.unregister();
  }
}
