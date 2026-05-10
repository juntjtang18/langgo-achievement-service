import { createServer } from 'node:http';
import { loadConfig } from './config';
import { Database } from './db';
import { createLogger } from './logger';
import { AchievementRepository } from './repositories/achievementRepository';
import { createApp } from './app';
import { AchievementService } from './services/achievementService';
import { ProgressService } from './services/progressService';
import { EventHandlerService } from './services/eventHandler';
import { EventSubscriberService } from './services/eventSubscriberService';
import { createEventBus } from 'event-bus-client';

async function main() {
  const config = loadConfig();
  const logger = createLogger(config.logLevel);
  const db = new Database(config, logger);

  await db.initialize();

  const repository = new AchievementRepository(db);
  const achievementService = new AchievementService(repository);
  const progressService = new ProgressService(db, repository, logger);
  const eventHandler = new EventHandlerService(progressService);
  const eventBus = createEventBus({
    driver: 'postgres',
    config: {
      connectionString: process.env.EVENT_BUS_POSTGRES_URL ?? '',
      channelPrefix: process.env.EVENT_BUS_CHANNEL_PREFIX ?? 'event_bus',
    },
    logger,
  });
  const subscriberService = new EventSubscriberService(repository, eventBus, eventHandler, logger);

  await subscriberService.register();

  const app = createApp(achievementService, logger, config.internalKey);
  const httpServer = createServer(app);

  const shutdown = async (signal: string) => {
    logger.info({ signal }, 'shutting down achievement server');
    httpServer.close();
    await subscriberService.close().catch((error) => logger.error({ err: error }, 'failed to close subscribers'));
    await eventBus.close().catch((error) => logger.error({ err: error }, 'failed to close event bus'));
    await db.close().catch((error) => logger.error({ err: error }, 'failed to close database'));
    process.exit(0);
  };

  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  httpServer.listen(config.port, () => {
    logger.info({ port: config.port }, 'achievement server listening');
  });
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
