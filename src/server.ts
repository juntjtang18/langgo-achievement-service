import { createServer } from 'node:http';
import { loadConfig } from './config';
import { Database } from './db';
import { createEventBusLogger, createLogger } from './logger';
import { AdminRepository } from './repositories/adminRepository';
import { AchievementRepository } from './repositories/achievementRepository';
import { createApp } from './app';
import { AchievementService } from './services/achievementService';
import { AdminAuthService } from './services/adminAuthService';
import { ProgressService } from './services/progressService';
import { EventHandlerService } from './services/eventHandler';
import { EventSubscriberService } from './services/eventSubscriberService';
import { createEventBus } from 'event-bus-client';

async function main() {
  const config = loadConfig();
  const logger = createLogger(config.logLevel);
  const eventBusLogger = createEventBusLogger(logger);
  const db = new Database(config, logger);

  await db.initialize();

  const repository = new AchievementRepository(db);
  const adminRepository = new AdminRepository(db);
  const adminAuthService = new AdminAuthService(config.strapiAdminUrl);
  const achievementService = new AchievementService(repository);
  const progressService = new ProgressService(db, repository, logger);
  const eventHandler = new EventHandlerService(progressService);
  const eventBus = createEventBus({
    driver: 'postgres',
    config: {
      connectionString: process.env.EVENT_BUS_POSTGRES_URL ?? '',
      channelPrefix: process.env.EVENT_BUS_CHANNEL_PREFIX ?? 'event_bus',
    },
    logger: eventBusLogger,
  });
  const subscriberService = new EventSubscriberService(repository, eventBus, eventHandler, logger);

  logger.info(
    {
      driver: eventBus.driver,
      channelPrefix: process.env.EVENT_BUS_CHANNEL_PREFIX ?? 'event_bus',
    },
    'Event bus enabled'
  );

  await subscriberService.register();

  const app = createApp({
    achievementService,
    logger,
    internalKey: config.internalKey,
    adminRepository,
    adminAuthService,
    eventBus,
    subscriberService,
  });
  const httpServer = createServer(app);

  const shutdown = async (signal: string) => {
    logger.info({ signal }, 'Shutting down server');
    httpServer.close();
    await subscriberService.close().catch((error) => logger.error({ err: error }, 'failed to close subscribers'));
    await eventBus.close().catch((error) => logger.error({ err: error }, 'failed to close event bus'));
    await db.close().catch((error) => logger.error({ err: error }, 'failed to close database'));
    process.exit(0);
  };

  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  httpServer.listen(config.port, () => {
    logger.info({ port: config.port }, 'Server listening');
  });
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
