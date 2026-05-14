import express from 'express';
import pinoHttp from 'pino-http';
import type { Logger } from 'pino';
import { createInternalKeyMiddleware } from './http/auth';
import { createAdminRouter } from './http/adminRouter';
import { createRouter } from './http/routes';
import { AdminRepository } from './repositories/adminRepository';
import { AchievementService } from './services/achievementService';
import { AdminAuthService } from './services/adminAuthService';
import { EventSubscriberService } from './services/eventSubscriberService';
import type { EventBus } from './types';

interface CreateAppOptions {
  achievementService: AchievementService;
  logger: Logger;
  internalKey: string;
  adminRepository: AdminRepository;
  adminAuthService: AdminAuthService;
  eventBus: EventBus;
  subscriberService: EventSubscriberService;
}

export function createApp(options: CreateAppOptions) {
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true, limit: '1mb' }));
  app.use(pinoHttp({ logger: options.logger }));
  app.use('/admin', createAdminRouter({
    authService: options.adminAuthService,
    repository: options.adminRepository,
    eventBus: options.eventBus,
    subscriberService: options.subscriberService,
    logger: options.logger,
    internalKey: options.internalKey,
    achievementService: options.achievementService,
  }));
  app.use(createInternalKeyMiddleware(options.internalKey));
  app.use(createRouter(options.achievementService));

  app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    const message = error instanceof Error ? error.message : 'Internal Server Error';
    const statusCode = message.includes('x-user-id') ? 400 : 500;
    options.logger.error({ err: error }, 'request failed');
    res.status(statusCode).json({ error: message });
  });

  return app;
}
