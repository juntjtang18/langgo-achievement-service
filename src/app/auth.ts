import type { Request, Response, NextFunction } from 'express';

export function createInternalKeyMiddleware(expectedKey: string) {
  return function internalKeyMiddleware(req: Request, res: Response, next: NextFunction) {
    const providedKey = req.header('x-internal-key');
    if (!providedKey || providedKey !== expectedKey) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    next();
  };
}
