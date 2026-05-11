import type { Request, Response, Router } from 'express';
import express from 'express';
import type { Logger } from 'pino';
import type { EventBus } from '../types';
import {
  AdminRepository,
  type AdminAchievementRow,
  type AdminEventListRow,
  type AdminTranslationRow,
  type AdminUserAchievementRow,
} from '../repositories/adminRepository';
import { AdminAuthService } from '../services/adminAuthService';
import { EventSubscriberService } from '../services/eventSubscriberService';

const SESSION_COOKIE = 'achievement_admin_session';

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function parseCookies(req: Request): Record<string, string> {
  const header = req.header('cookie');
  if (!header) {
    return {};
  }

  return header.split(';').reduce<Record<string, string>>((cookies, pair) => {
    const index = pair.indexOf('=');
    if (index === -1) {
      return cookies;
    }
    const key = pair.slice(0, index).trim();
    const value = pair.slice(index + 1).trim();
    cookies[key] = decodeURIComponent(value);
    return cookies;
  }, {});
}

function setSessionCookie(res: Response, sessionId: string): void {
  res.setHeader('Set-Cookie', `${SESSION_COOKIE}=${encodeURIComponent(sessionId)}; Path=/; HttpOnly; SameSite=Lax`);
}

function clearSessionCookie(res: Response): void {
  res.setHeader('Set-Cookie', `${SESSION_COOKIE}=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0`);
}

function redirectWithNotice(res: Response, path: string, type: 'notice' | 'error', message: string): void {
  const url = new URL(`http://local${path}`);
  url.searchParams.set(type, message);
  res.redirect(url.pathname + url.search + url.hash);
}

function readRequiredString(body: unknown, field: string): string {
  const value = typeof body === 'object' && body !== null ? (body as Record<string, unknown>)[field] : undefined;
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`Missing required field "${field}".`);
  }
  return value.trim();
}

function readOptionalString(body: unknown, field: string): string | null {
  const value = typeof body === 'object' && body !== null ? (body as Record<string, unknown>)[field] : undefined;
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.trim();
  return trimmed === '' ? null : trimmed;
}

function readRequiredNumber(body: unknown, field: string): number {
  const raw = readRequiredString(body, field);
  const value = Number(raw);
  if (!Number.isFinite(value)) {
    throw new Error(`Invalid number for "${field}".`);
  }
  return value;
}

function readBoolean(body: unknown, field: string): boolean {
  const value = typeof body === 'object' && body !== null ? (body as Record<string, unknown>)[field] : undefined;
  return value === 'true' || value === 'on' || value === true;
}

function readSessionId(req: Request): string | null {
  return parseCookies(req)[SESSION_COOKIE] ?? null;
}

function renderLayout(title: string, content: string, options: { notice?: string | null; error?: string | null; userEmail?: string | null } = {}): string {
  const notice = options.notice ? `<div class="banner success">${escapeHtml(options.notice)}</div>` : '';
  const error = options.error ? `<div class="banner error">${escapeHtml(options.error)}</div>` : '';
  const userEmail = options.userEmail ? `<div class="user">${escapeHtml(options.userEmail)}</div>` : '';

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${escapeHtml(title)}</title>
    <style>
      :root {
        --bg: #f5f6f8;
        --surface: #ffffff;
        --line: #d9dde5;
        --text: #1c2430;
        --muted: #6a7381;
        --accent: #4945ff;
        --accent-2: #f0efff;
        --danger: #d02b20;
        --success: #157347;
      }
      * { box-sizing: border-box; }
      body { margin: 0; font-family: Inter, ui-sans-serif, system-ui, sans-serif; color: var(--text); background: var(--bg); }
      a { color: inherit; }
      .shell { display: grid; grid-template-columns: 240px minmax(0, 1fr); min-height: 100vh; }
      .sidebar { background: #101828; color: #f8fafc; padding: 24px 18px; }
      .brand { font-weight: 700; font-size: 18px; margin-bottom: 20px; }
      .brand small { display: block; color: #98a2b3; font-weight: 500; margin-top: 6px; }
      .nav a { display: block; padding: 10px 12px; border-radius: 10px; text-decoration: none; color: #d0d5dd; margin-bottom: 6px; }
      .nav a:hover { background: rgba(255,255,255,0.08); color: #fff; }
      .main { padding: 24px; }
      .topbar { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
      .topbar h1 { margin: 0; font-size: 28px; }
      .user { color: var(--muted); font-size: 14px; }
      .logout { text-decoration: none; padding: 10px 14px; border-radius: 10px; border: 1px solid var(--line); background: var(--surface); }
      .banner { padding: 12px 14px; border-radius: 12px; margin-bottom: 18px; }
      .banner.success { background: #e9f7ef; color: var(--success); border: 1px solid #b8e0c5; }
      .banner.error { background: #fff0ee; color: var(--danger); border: 1px solid #f4c7c3; }
      .grid { display: grid; gap: 20px; }
      .card { background: var(--surface); border: 1px solid var(--line); border-radius: 16px; padding: 18px; box-shadow: 0 8px 24px rgba(16,24,40,0.05); overflow: auto; }
      .card h2 { margin: 0 0 14px; font-size: 20px; }
      .subtle { color: var(--muted); font-size: 13px; margin-bottom: 14px; }
      .row { display: grid; grid-template-columns: repeat(6, minmax(120px, 1fr)); gap: 10px; margin-bottom: 12px; }
      .row.compact { grid-template-columns: repeat(4, minmax(120px, 1fr)); }
      .field { display: flex; flex-direction: column; gap: 6px; }
      .field label { font-size: 12px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; }
      input, textarea, select, button { font: inherit; }
      input, textarea, select { width: 100%; border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; background: #fff; }
      textarea { min-height: 84px; resize: vertical; }
      .actions { display: flex; gap: 10px; flex-wrap: wrap; }
      button { border: 0; border-radius: 10px; padding: 10px 14px; cursor: pointer; background: var(--accent); color: #fff; font-weight: 600; }
      button.secondary { background: #eef2f6; color: var(--text); }
      button.danger { background: #b42318; }
      table { width: 100%; border-collapse: collapse; min-width: 980px; }
      th, td { text-align: left; padding: 10px 8px; border-bottom: 1px solid var(--line); vertical-align: top; }
      th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); }
      .stack { display: grid; gap: 12px; }
      .login-shell { min-height: 100vh; display: grid; place-items: center; padding: 24px; }
      .login-card { width: min(420px, 100%); background: var(--surface); border: 1px solid var(--line); border-radius: 20px; padding: 24px; box-shadow: 0 18px 50px rgba(16,24,40,0.12); }
      .login-card h1 { margin-top: 0; margin-bottom: 10px; }
      .login-card p { color: var(--muted); }
      .login-card .field { margin-bottom: 14px; }
      .tag { display: inline-block; padding: 2px 8px; border-radius: 999px; background: var(--accent-2); color: var(--accent); font-size: 12px; font-weight: 600; }
      @media (max-width: 1100px) {
        .shell { grid-template-columns: 1fr; }
        .sidebar { display: none; }
        .row, .row.compact { grid-template-columns: repeat(2, minmax(120px, 1fr)); }
      }
      @media (max-width: 640px) {
        .main { padding: 16px; }
        .topbar { flex-direction: column; align-items: flex-start; }
        .row, .row.compact { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    ${content.replace('<!--NOTICE-->', `${notice}${error}`).replace('<!--USER-->', userEmail)}
  </body>
</html>`;
}

function renderLoginPage(strapiLoginUrl: string, notice?: string | null, error?: string | null): string {
  return renderLayout(
    'Achievement Admin Login',
    `<main class="login-shell">
      <section class="login-card">
        <span class="tag">Strapi-backed auth</span>
        <h1>Achievement Admin</h1>
        <p>Authenticate with the Strapi admin account at <a href="${escapeHtml(strapiLoginUrl)}" target="_blank" rel="noreferrer">${escapeHtml(strapiLoginUrl)}</a>.</p>
        <!--NOTICE-->
        <form method="post" action="/admin/login" class="stack">
          <div class="field">
            <label>Email</label>
            <input name="email" type="email" required />
          </div>
          <div class="field">
            <label>Password</label>
            <input name="password" type="password" required />
          </div>
          <button type="submit">Sign in with Strapi</button>
        </form>
      </section>
    </main>`,
    { notice, error }
  );
}

function renderAdminPage(data: {
  achievements: AdminAchievementRow[];
  translations: AdminTranslationRow[];
  eventLists: AdminEventListRow[];
  userAchievements: AdminUserAchievementRow[];
  notice?: string | null;
  error?: string | null;
  userEmail: string;
}): string {
  const achievementRows = data.achievements.map((row) => `
    <tr>
      <form method="post" action="/admin/achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input name="code" value="${escapeHtml(row.code)}" /></td>
        <td><input name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input name="icon_name" value="${escapeHtml(row.icon_name ?? '')}" /></td>
        <td><input name="points" type="number" value="${row.points}" /></td>
        <td><input name="goal" type="number" value="${row.goal}" /></td>
        <td class="actions">
          <button type="submit">Save</button>
      </form>
      <form method="post" action="/admin/achievements/${row.id}/delete">
          <button class="danger" type="submit">Delete</button>
      </form>
        </td>
    </tr>`).join('');

  const translationRows = data.translations.map((row) => `
    <tr>
      <form method="post" action="/admin/translations/${row.id}/update">
        <td>${row.id}</td>
        <td><input name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input name="locale" value="${escapeHtml(row.locale)}" /></td>
        <td><input name="title" value="${escapeHtml(row.title ?? '')}" /></td>
        <td><textarea name="description">${escapeHtml(row.description ?? '')}</textarea></td>
        <td class="actions">
          <button type="submit">Save</button>
      </form>
      <form method="post" action="/admin/translations/${row.id}/delete">
          <button class="danger" type="submit">Delete</button>
      </form>
        </td>
    </tr>`).join('');

  const eventRows = data.eventLists.map((row) => `
    <tr>
      <form method="post" action="/admin/event-lists/${row.id}/update">
        <td>${row.id}</td>
        <td><input name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input name="points" type="number" value="${row.points}" /></td>
        <td class="actions">
          <button type="submit">Save</button>
      </form>
      <form method="post" action="/admin/event-lists/${row.id}/delete">
          <button class="danger" type="submit">Delete</button>
      </form>
        </td>
    </tr>`).join('');

  const userAchievementRows = data.userAchievements.map((row) => `
    <tr>
      <form method="post" action="/admin/user-achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input name="userid" value="${escapeHtml(row.userid)}" /></td>
        <td><input name="username" value="${escapeHtml(row.username ?? '')}" /></td>
        <td><input name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input name="progress" type="number" value="${row.progress}" /></td>
        <td><input name="achieved" type="checkbox" ${row.achieved ? 'checked' : ''} /></td>
        <td><input name="achieved_at" value="${escapeHtml(row.achieved_at ?? '')}" /></td>
        <td class="actions">
          <button type="submit">Save</button>
      </form>
      <form method="post" action="/admin/user-achievements/${row.id}/delete">
          <button class="danger" type="submit">Delete</button>
      </form>
        </td>
    </tr>`).join('');

  return renderLayout(
    'Achievement Admin',
    `<div class="shell">
      <aside class="sidebar">
        <div class="brand">Achievement Admin<small>Standalone service control plane</small></div>
        <nav class="nav">
          <a href="#emit">Manual Event Emit</a>
          <a href="#achievements">Achievements</a>
          <a href="#translations">Translations</a>
          <a href="#event-lists">Event Lists</a>
          <a href="#user-achievements">User Achievements</a>
        </nav>
      </aside>
      <main class="main">
        <div class="topbar">
          <div>
            <h1>Achievement Service Admin</h1>
            <!--USER-->
          </div>
          <a class="logout" href="/admin/logout">Logout</a>
        </div>
        <!--NOTICE-->
        <div class="grid">
          <section id="emit" class="card">
            <h2>Manual Event Emit</h2>
            <div class="subtle">Publish an event into the configured event bus to exercise the live achievement logic.</div>
            <form method="post" action="/admin/events/emit" class="stack">
              <div class="row compact">
                <div class="field">
                  <label>Topic</label>
                  <input name="topic" placeholder="flashcard.review" required />
                </div>
                <div class="field">
                  <label>Payload JSON</label>
                  <textarea name="payload_json" placeholder='{"userid":"8","username":"vivian"}' required></textarea>
                </div>
              </div>
              <div class="actions">
                <button type="submit">Emit Event</button>
                <button class="secondary" type="submit" formaction="/admin/subscriptions/refresh">Refresh Subscriptions</button>
              </div>
            </form>
          </section>
          <section id="achievements" class="card">
            <h2>Achievements</h2>
            <div class="subtle">Manage achievement definitions stored in <code>as_achievements</code>.</div>
            <form method="post" action="/admin/achievements/create" class="stack">
              <div class="row">
                <div class="field"><label>Code</label><input name="code" required /></div>
                <div class="field"><label>Event Name</label><input name="event_name" required /></div>
                <div class="field"><label>Icon Name</label><input name="icon_name" /></div>
                <div class="field"><label>Points</label><input name="points" type="number" value="1" required /></div>
                <div class="field"><label>Goal</label><input name="goal" type="number" value="1" required /></div>
              </div>
              <button type="submit">Create Achievement</button>
            </form>
            <table>
              <thead><tr><th>ID</th><th>Code</th><th>Event</th><th>Icon</th><th>Points</th><th>Goal</th><th>Actions</th></tr></thead>
              <tbody>${achievementRows}</tbody>
            </table>
          </section>
          <section id="translations" class="card">
            <h2>Translations</h2>
            <div class="subtle">Manage localized title and description rows in <code>as_achievement_translations</code>.</div>
            <form method="post" action="/admin/translations/create" class="stack">
              <div class="row">
                <div class="field"><label>Achievement ID</label><input name="achievement_id" type="number" required /></div>
                <div class="field"><label>Locale</label><input name="locale" value="en" required /></div>
                <div class="field"><label>Title</label><input name="title" /></div>
                <div class="field"><label>Description</label><textarea name="description"></textarea></div>
              </div>
              <button type="submit">Create Translation</button>
            </form>
            <table>
              <thead><tr><th>ID</th><th>Achievement ID</th><th>Locale</th><th>Title</th><th>Description</th><th>Actions</th></tr></thead>
              <tbody>${translationRows}</tbody>
            </table>
          </section>
          <section id="event-lists" class="card">
            <h2>Event Lists</h2>
            <div class="subtle">Manage subscribed event topics in <code>as_event_lists</code>. Saving changes should be followed by a subscription refresh.</div>
            <form method="post" action="/admin/event-lists/create" class="stack">
              <div class="row compact">
                <div class="field"><label>Event Name</label><input name="event_name" required /></div>
                <div class="field"><label>Points</label><input name="points" type="number" value="1" required /></div>
              </div>
              <button type="submit">Create Event List Row</button>
            </form>
            <table>
              <thead><tr><th>ID</th><th>Event Name</th><th>Points</th><th>Actions</th></tr></thead>
              <tbody>${eventRows}</tbody>
            </table>
          </section>
          <section id="user-achievements" class="card">
            <h2>User Achievements</h2>
            <div class="subtle">Latest 200 rows from <code>as_user_achievements</code>. Querying is by <code>userid</code>; username is stored only as display metadata.</div>
            <table>
              <thead><tr><th>ID</th><th>User ID</th><th>Username</th><th>Achievement ID</th><th>Progress</th><th>Achieved</th><th>Achieved At</th><th>Actions</th></tr></thead>
              <tbody>${userAchievementRows}</tbody>
            </table>
          </section>
        </div>
      </main>
    </div>`,
    { notice: data.notice, error: data.error, userEmail: data.userEmail }
  );
}

interface AdminRouterDependencies {
  authService: AdminAuthService;
  repository: AdminRepository;
  eventBus: EventBus;
  subscriberService: EventSubscriberService;
  logger: Logger;
}

export function createAdminRouter(deps: AdminRouterDependencies): Router {
  const router = express.Router();

  router.get('/login', (req, res) => {
    const session = deps.authService.getSession(readSessionId(req));
    if (session) {
      res.redirect('/admin');
      return;
    }

    const notice = typeof req.query.notice === 'string' ? req.query.notice : null;
    const error = typeof req.query.error === 'string' ? req.query.error : null;
    res.type('html').send(renderLoginPage(deps.authService.getLoginUrl(), notice, error));
  });

  router.post('/login', async (req, res) => {
    try {
      const email = readRequiredString(req.body, 'email');
      const password = readRequiredString(req.body, 'password');
      const session = await deps.authService.login(email, password);
      setSessionCookie(res, session.id);
      redirectWithNotice(res, '/admin', 'notice', 'Signed in successfully.');
    } catch (error) {
      deps.logger.error({ err: error }, 'admin login failed');
      const message = error instanceof Error ? error.message : 'Login failed.';
      redirectWithNotice(res, '/admin/login', 'error', message);
    }
  });

  router.use((req, res, next) => {
    const session = deps.authService.getSession(readSessionId(req));
    if (!session) {
      redirectWithNotice(res, '/admin/login', 'error', 'Please sign in with Strapi admin.');
      return;
    }

    res.locals.adminSession = session;
    next();
  });

  router.get('/logout', (req, res) => {
    deps.authService.deleteSession(readSessionId(req));
    clearSessionCookie(res);
    redirectWithNotice(res, '/admin/login', 'notice', 'Signed out.');
  });

  router.get('/', async (req, res) => {
    try {
      const [achievements, translations, eventLists, userAchievements] = await Promise.all([
        deps.repository.listAchievements(),
        deps.repository.listTranslations(),
        deps.repository.listEventLists(),
        deps.repository.listUserAchievements(),
      ]);

      res.type('html').send(renderAdminPage({
        achievements,
        translations,
        eventLists,
        userAchievements,
        notice: typeof req.query.notice === 'string' ? req.query.notice : null,
        error: typeof req.query.error === 'string' ? req.query.error : null,
        userEmail: res.locals.adminSession.email,
      }));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render admin page');
      redirectWithNotice(res, '/admin', 'error', 'Failed to load admin data.');
    }
  });

  router.post('/subscriptions/refresh', async (_req, res) => {
    try {
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin', 'notice', 'Event subscriptions refreshed.');
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to refresh subscriptions');
      redirectWithNotice(res, '/admin', 'error', 'Failed to refresh event subscriptions.');
    }
  });

  router.post('/events/emit', async (req, res) => {
    try {
      const topic = readRequiredString(req.body, 'topic');
      const payloadJson = readRequiredString(req.body, 'payload_json');
      const payload = JSON.parse(payloadJson);
      const ack = await deps.eventBus.publish(topic, payload);
      redirectWithNotice(res, '/admin', 'notice', `Event published to ${ack.topic} at ${ack.publishedAt}.`);
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to emit manual event');
      redirectWithNotice(res, '/admin', 'error', error instanceof Error ? error.message : 'Failed to emit event.');
    }
  });

  router.post('/achievements/create', async (req, res) => {
    try {
      await deps.repository.createAchievement({
        code: readRequiredString(req.body, 'code'),
        event_name: readRequiredString(req.body, 'event_name'),
        icon_name: readOptionalString(req.body, 'icon_name'),
        points: readRequiredNumber(req.body, 'points'),
        goal: readRequiredNumber(req.body, 'goal'),
      });
      redirectWithNotice(res, '/admin#achievements', 'notice', 'Achievement created.');
    } catch (error) {
      redirectWithNotice(res, '/admin#achievements', 'error', error instanceof Error ? error.message : 'Failed to create achievement.');
    }
  });

  router.post('/achievements/:id/update', async (req, res) => {
    try {
      await deps.repository.updateAchievement(Number(req.params.id), {
        code: readRequiredString(req.body, 'code'),
        event_name: readRequiredString(req.body, 'event_name'),
        icon_name: readOptionalString(req.body, 'icon_name'),
        points: readRequiredNumber(req.body, 'points'),
        goal: readRequiredNumber(req.body, 'goal'),
      });
      redirectWithNotice(res, '/admin#achievements', 'notice', 'Achievement updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin#achievements', 'error', error instanceof Error ? error.message : 'Failed to update achievement.');
    }
  });

  router.post('/achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteAchievement(Number(req.params.id));
      redirectWithNotice(res, '/admin#achievements', 'notice', 'Achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin#achievements', 'error', error instanceof Error ? error.message : 'Failed to delete achievement.');
    }
  });

  router.post('/translations/create', async (req, res) => {
    try {
      await deps.repository.createTranslation({
        achievement_id: readRequiredNumber(req.body, 'achievement_id'),
        locale: readRequiredString(req.body, 'locale'),
        title: readOptionalString(req.body, 'title'),
        description: readOptionalString(req.body, 'description'),
      });
      redirectWithNotice(res, '/admin#translations', 'notice', 'Translation created.');
    } catch (error) {
      redirectWithNotice(res, '/admin#translations', 'error', error instanceof Error ? error.message : 'Failed to create translation.');
    }
  });

  router.post('/translations/:id/update', async (req, res) => {
    try {
      await deps.repository.updateTranslation(Number(req.params.id), {
        achievement_id: readRequiredNumber(req.body, 'achievement_id'),
        locale: readRequiredString(req.body, 'locale'),
        title: readOptionalString(req.body, 'title'),
        description: readOptionalString(req.body, 'description'),
      });
      redirectWithNotice(res, '/admin#translations', 'notice', 'Translation updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin#translations', 'error', error instanceof Error ? error.message : 'Failed to update translation.');
    }
  });

  router.post('/translations/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteTranslation(Number(req.params.id));
      redirectWithNotice(res, '/admin#translations', 'notice', 'Translation deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin#translations', 'error', error instanceof Error ? error.message : 'Failed to delete translation.');
    }
  });

  router.post('/event-lists/create', async (req, res) => {
    try {
      await deps.repository.createEventList({
        event_name: readRequiredString(req.body, 'event_name'),
        points: readRequiredNumber(req.body, 'points'),
      });
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin#event-lists', 'notice', 'Event list row created and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin#event-lists', 'error', error instanceof Error ? error.message : 'Failed to create event list row.');
    }
  });

  router.post('/event-lists/:id/update', async (req, res) => {
    try {
      await deps.repository.updateEventList(Number(req.params.id), {
        event_name: readRequiredString(req.body, 'event_name'),
        points: readRequiredNumber(req.body, 'points'),
      });
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin#event-lists', 'notice', 'Event list row updated and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin#event-lists', 'error', error instanceof Error ? error.message : 'Failed to update event list row.');
    }
  });

  router.post('/event-lists/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteEventList(Number(req.params.id));
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin#event-lists', 'notice', 'Event list row deleted and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin#event-lists', 'error', error instanceof Error ? error.message : 'Failed to delete event list row.');
    }
  });

  router.post('/user-achievements/:id/update', async (req, res) => {
    try {
      await deps.repository.updateUserAchievement(Number(req.params.id), {
        userid: readRequiredString(req.body, 'userid'),
        username: readOptionalString(req.body, 'username'),
        achievement_id: readRequiredNumber(req.body, 'achievement_id'),
        progress: readRequiredNumber(req.body, 'progress'),
        achieved: readBoolean(req.body, 'achieved'),
        achieved_at: readOptionalString(req.body, 'achieved_at'),
      });
      redirectWithNotice(res, '/admin#user-achievements', 'notice', 'User achievement updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin#user-achievements', 'error', error instanceof Error ? error.message : 'Failed to update user achievement.');
    }
  });

  router.post('/user-achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteUserAchievement(Number(req.params.id));
      redirectWithNotice(res, '/admin#user-achievements', 'notice', 'User achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin#user-achievements', 'error', error instanceof Error ? error.message : 'Failed to delete user achievement.');
    }
  });

  return router;
}
