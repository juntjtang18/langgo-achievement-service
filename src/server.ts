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
import { AchievementEventQueue } from './services/achievementEventQueue';
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
  const eventHandler = new EventHandlerService(progressService, repository);
  const eventQueue = new AchievementEventQueue(config.workerConcurrency, config.workerQueueLimit);
  const eventBus = createEventBus({
    driver: config.eventBus.driver,
    config: {
      connectionString: config.eventBus.postgresUrl,
      channelPrefix: config.eventBus.channelPrefix,
    },
    logger: eventBusLogger,
  });
  const subscriberService = new EventSubscriberService(repository, eventBus, eventHandler, eventQueue, logger);

  logger.info(
    {
      driver: eventBus.driver,
      channelPrefix: config.eventBus.channelPrefix,
      workerConcurrency: config.workerConcurrency,
      workerQueueLimit: config.workerQueueLimit,
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
  let isShuttingDown = false;

  const closeResources = async () => {
    await withShutdownTimeout(
      subscriberService.close(),
      500,
      () => logger.warn({}, 'achievement event unsubscribe timed out during shutdown')
    ).catch((error) => logger.error({ err: error }, 'failed to close subscribers'));
    await withShutdownTimeout(
      eventBus.close(),
      25,
      () => logger.warn({}, 'event bus close timed out during shutdown')
    ).catch((error) => logger.error({ err: error }, 'failed to close event bus'));
    await db.close().catch((error) => logger.error({ err: error }, 'failed to close database'));
  };

  const shutdown = async (signal: string) => {
    if (isShuttingDown) {
      return;
    }

    isShuttingDown = true;
    logger.info({ signal }, 'Shutting down server');
    httpServer.close((error) => {
      if (error) {
        logger.error({ err: error }, 'failed to close HTTP server');
      }
    });
    httpServer.closeIdleConnections?.();
    httpServer.closeAllConnections?.();
    await closeResources();
    logger.info({}, 'achievement server shutdown complete');
    process.exit(0);
  };

  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  httpServer.on('error', (error) => {
    if (isShuttingDown) {
      return;
    }

    isShuttingDown = true;
    logger.error({ err: error }, 'achievement server listen failed');
    void closeResources().finally(() => process.exit(1));
  });

  httpServer.listen(config.port, () => {
    logger.info({ port: config.port }, 'Server listening');
  });
}

async function withShutdownTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  onTimeout: () => void
): Promise<T | undefined> {
  let timeout: NodeJS.Timeout | undefined;

  return Promise.race([
    promise,
    new Promise<undefined>((resolve) => {
      timeout = setTimeout(() => {
        onTimeout();
        resolve(undefined);
      }, timeoutMs);
    }),
  ]).finally(() => {
    if (timeout) {
      clearTimeout(timeout);
    }
  });
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
