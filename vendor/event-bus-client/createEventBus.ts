import { resolveLogger } from './logger';
import { PostgresDriver } from './drivers/postgres';
import type { EventBus, EventBusLogger } from './types';

export function createEventBusFromEnv(options?: { logger?: EventBusLogger }): EventBus {
  const driver = process.env.EVENT_BUS_DRIVER ?? 'postgres';

  if (driver !== 'postgres') {
    throw new Error(`Unsupported EVENT_BUS_DRIVER "${driver}". Supported drivers: postgres.`);
  }

  const connectionString = process.env.EVENT_BUS_POSTGRES_URL;
  if (!connectionString) {
    throw new Error('Missing required environment variable "EVENT_BUS_POSTGRES_URL" for event-bus-client.');
  }

  const logger = resolveLogger(options?.logger);
  const postgresDriver = new PostgresDriver(
    {
      connectionString,
      channelPrefix: process.env.EVENT_BUS_CHANNEL_PREFIX ?? 'event_bus',
    },
    logger
  );

  return {
    subscribe: postgresDriver.subscribe.bind(postgresDriver),
    close: postgresDriver.close.bind(postgresDriver),
  };
}
