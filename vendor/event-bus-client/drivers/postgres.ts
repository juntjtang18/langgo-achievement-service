import { Client } from 'pg';
import { maskConnectionString } from '../logger';
import type { EventBusLogger, EventMessage, SubscriptionHandle } from '../types';

interface PostgresMessageShape<TPayload = unknown> {
  topic: string;
  payload: TPayload;
  publishedAt: string;
}

function sanitizeName(value: string): string {
  return value.replace(/[^a-zA-Z0-9_]/g, '_');
}

export class PostgresDriver {
  private subscriber?: Client;

  constructor(
    private readonly config: { connectionString: string; channelPrefix?: string },
    private readonly logger: EventBusLogger
  ) {}

  async subscribe<TPayload = unknown>(
    topic: string,
    handler: (message: EventMessage<TPayload>) => Promise<void> | void
  ): Promise<SubscriptionHandle> {
    const client = await this.getSubscriber();
    const channel = this.getChannelName(topic);

    this.logger.info('[event-bus-client] subscribing to event', {
      driver: 'postgres',
      topic,
      channel,
    });

    await client.query(`LISTEN ${channel}`);

    const notificationListener = (message: { channel: string; payload?: string }) => {
      if (message.channel !== channel || !message.payload) {
        return;
      }

      const parsed = JSON.parse(message.payload) as PostgresMessageShape<TPayload>;
      void handler({
        topic: parsed.topic ?? topic,
        payload: parsed.payload,
        publishedAt: parsed.publishedAt,
        raw: message,
        ack: async () => undefined,
        nack: async () => undefined,
      });
    };

    client.on('notification', notificationListener);

    return {
      topic,
      unsubscribe: async () => {
        client.removeListener('notification', notificationListener);
        await client.query(`UNLISTEN ${channel}`);
      },
    };
  }

  async close(): Promise<void> {
    if (this.subscriber) {
      await this.subscriber.end();
      this.subscriber = undefined;
    }
  }

  private async getSubscriber(): Promise<Client> {
    if (this.subscriber) {
      return this.subscriber;
    }

    this.logger.info('[event-bus-client] connecting Postgres subscriber', {
      driver: 'postgres',
      connectionString: maskConnectionString(this.config.connectionString),
    });

    this.subscriber = new Client({ connectionString: this.config.connectionString });
    await this.subscriber.connect();
    return this.subscriber;
  }

  private getChannelName(topic: string): string {
    const prefix = this.config.channelPrefix ?? 'event_bus';
    return sanitizeName(`${prefix}_${topic}`);
  }
}
