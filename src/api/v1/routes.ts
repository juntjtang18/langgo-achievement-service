import { Router, type Request, type Response, type Router as ExpressRouter } from 'express';
import { AchievementService } from '../../services/achievementService';

export function readUserContext(req: Request): { userId: string; locale: string } {
  const userId = req.header('x-user-id');
  if (!userId) {
    throw new Error('Missing x-user-id header');
  }

  return {
    userId,
    locale: typeof req.query.locale === 'string' && req.query.locale.length > 0 ? req.query.locale : 'en',
  };
}

export function registerApiRoutes(router: ExpressRouter, achievementService: AchievementService): void {
  router.get('/healthz', (_req: Request, res: Response) => {
    res.json({ ok: true });
  });

  router.get('/achievements-achieved', async (req, res, next) => {
    try {
      const { userId, locale } = readUserContext(req);
      await achievementService.ensureUserAchievements(userId);
      const rows = await achievementService.listAchievedByUserid(userId, locale);
      res.json({ data: rows });
    } catch (error) {
      next(error);
    }
  });

  router.get('/achievements-not-achieved', async (req, res, next) => {
    try {
      const { userId, locale } = readUserContext(req);
      await achievementService.ensureUserAchievements(userId);
      const rows = await achievementService.listNotAchievedByUserid(userId, locale);
      res.json({ data: rows });
    } catch (error) {
      next(error);
    }
  });
}

export function createRouter(achievementService: AchievementService): Router {
  const router = Router();
  registerApiRoutes(router, achievementService);
  return router;
}
