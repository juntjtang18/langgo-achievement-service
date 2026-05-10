import express from 'express';
import pinoHttp from 'pino-http';
import type { Logger } from 'pino';
import { createInternalKeyMiddleware } from './http/auth';
import { createRouter } from './http/routes';
import { AchievementService } from './services/achievementService';

export function createApp(achievementService: AchievementService, logger: Logger, internalKey: string) {
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json({ limit: '1mb' }));
  app.use(pinoHttp({ logger }));
  app.use(createInternalKeyMiddleware(internalKey));
  app.use(createRouter(achievementService));

  app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    const message = error instanceof Error ? error.message : 'Internal Server Error';
    const statusCode = message.includes('x-user-id') ? 400 : 500;
    logger.error({ err: error }, 'request failed');
    res.status(statusCode).json({ error: message });
  });

  return app;
}
