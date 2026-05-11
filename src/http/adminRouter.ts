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
const DEFAULT_ADMIN_PATH = '/admin/events';

type AdminSection = 'events' | 'achievements' | 'translations' | 'event-lists' | 'user-achievements';

interface AdminLayoutOptions {
  notice?: string | null;
  error?: string | null;
  userEmail?: string | null;
  activeSection?: AdminSection;
}

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

function navLink(section: AdminSection, href: string, label: string, activeSection?: AdminSection): string {
  const activeClass = activeSection === section ? 'active' : '';
  return `<a class="${activeClass}" href="${href}" aria-current="${activeSection === section ? 'page' : 'false'}">${escapeHtml(label)}</a>`;
}

function iconButton(options: {
  label: string;
  symbol: string;
  type?: 'submit' | 'button';
  tone?: 'default' | 'secondary' | 'danger';
  formaction?: string;
}): string {
  const toneClass = options.tone && options.tone !== 'default' ? ` ${options.tone}` : '';
  const formaction = options.formaction ? ` formaction="${escapeHtml(options.formaction)}"` : '';
  return `<button class="icon-button${toneClass}" type="${options.type ?? 'submit'}" title="${escapeHtml(options.label)}" aria-label="${escapeHtml(options.label)}"${formaction}>${escapeHtml(options.symbol)}</button>`;
}

function renderLayout(title: string, content: string, options: AdminLayoutOptions = {}): string {
  const notice = options.notice ? `<div class="banner success">${escapeHtml(options.notice)}</div>` : '';
  const error = options.error ? `<div class="banner error">${escapeHtml(options.error)}</div>` : '';
  const userEmail = options.userEmail ? `<div class="user">${escapeHtml(options.userEmail)}</div>` : '';
  const sidebar = options.activeSection
    ? `<aside class="sidebar">
        <div class="sidebar-inner">
          <div class="brand">Achievement Admin<small>Standalone service control plane</small></div>
          <nav class="nav">
            ${navLink('events', '/admin/events', 'Manual Event Emit', options.activeSection)}
            ${navLink('achievements', '/admin/achievements', 'Achievements', options.activeSection)}
            ${navLink('translations', '/admin/translations', 'Translations', options.activeSection)}
            ${navLink('event-lists', '/admin/event-lists', 'Event Lists', options.activeSection)}
            ${navLink('user-achievements', '/admin/user-achievements', 'User Achievements', options.activeSection)}
          </nav>
        </div>
      </aside>`
    : '';

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${escapeHtml(title)}</title>
    <style>
      :root {
        --bg: #f4f6fb;
        --surface: #ffffff;
        --surface-2: #f9fbff;
        --line: #d8dfeb;
        --line-strong: #c4ccda;
        --text: #18212f;
        --muted: #677489;
        --accent: #2563eb;
        --accent-ghost: #e8f0ff;
        --danger: #b42318;
        --danger-ghost: #fff1f0;
        --success: #157347;
        --success-ghost: #e9f7ef;
        --sidebar: #0f172a;
        --sidebar-text: #d6def0;
      }
      * { box-sizing: border-box; }
      body { margin: 0; font-family: Inter, ui-sans-serif, system-ui, sans-serif; color: var(--text); background: linear-gradient(180deg, #f8fbff 0%, var(--bg) 100%); }
      a { color: inherit; }
      .app-shell { min-height: 100vh; padding-left: 248px; }
      .sidebar { position: fixed; inset: 0 auto 0 0; width: 248px; background: linear-gradient(180deg, #0f172a 0%, #111b31 100%); color: var(--sidebar-text); border-right: 1px solid rgba(255,255,255,0.06); }
      .sidebar-inner { padding: 24px 16px; }
      .brand { font-weight: 700; font-size: 19px; color: #f8fafc; margin-bottom: 22px; }
      .brand small { display: block; margin-top: 6px; color: #94a3b8; font-size: 13px; font-weight: 500; }
      .nav { display: grid; gap: 8px; }
      .nav a { text-decoration: none; padding: 12px 14px; border-radius: 12px; color: var(--sidebar-text); font-weight: 600; transition: background 120ms ease, color 120ms ease; }
      .nav a:hover { background: rgba(255,255,255,0.08); color: #fff; }
      .nav a.active { background: linear-gradient(180deg, rgba(37,99,235,0.32), rgba(37,99,235,0.18)); color: #fff; box-shadow: inset 0 0 0 1px rgba(147,197,253,0.25); }
      .main { padding: 24px; }
      .topbar { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
      .topbar h1 { margin: 0; font-size: 28px; letter-spacing: -0.02em; }
      .user { color: var(--muted); font-size: 14px; margin-top: 6px; }
      .logout { text-decoration: none; padding: 10px 14px; border-radius: 12px; border: 1px solid var(--line); background: rgba(255,255,255,0.7); box-shadow: 0 8px 22px rgba(15,23,42,0.06); }
      .content-card { background: rgba(255,255,255,0.86); backdrop-filter: blur(10px); border: 1px solid var(--line); border-radius: 18px; padding: 18px; box-shadow: 0 14px 38px rgba(15,23,42,0.06); overflow: auto; }
      .section-header { display: flex; align-items: start; justify-content: space-between; gap: 16px; margin-bottom: 16px; }
      .section-header h2 { margin: 0 0 6px; font-size: 21px; }
      .subtle { color: var(--muted); font-size: 13px; margin: 0; }
      .banner { padding: 12px 14px; border-radius: 14px; margin-bottom: 18px; font-size: 14px; }
      .banner.success { background: var(--success-ghost); color: var(--success); border: 1px solid #b8e0c5; }
      .banner.error { background: #fff0ee; color: var(--danger); border: 1px solid #f4c7c3; }
      .form-grid { display: grid; grid-template-columns: repeat(4, minmax(140px, 1fr)); gap: 10px; margin-bottom: 16px; }
      .form-grid.wide { grid-template-columns: repeat(2, minmax(220px, 1fr)); }
      .field { display: flex; flex-direction: column; gap: 6px; }
      .field label { font-size: 12px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; }
      input, textarea, button { font: inherit; }
      input, textarea { width: 100%; border: 1px solid var(--line); border-radius: 10px; padding: 9px 11px; background: #fff; color: var(--text); }
      textarea { min-height: 110px; resize: vertical; }
      .toolbar { display: flex; gap: 10px; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; }
      .toolbar-actions, .cell-actions { display: flex; gap: 8px; align-items: center; }
      .icon-button { width: 36px; height: 36px; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--line); border-radius: 10px; background: var(--accent); color: #fff; cursor: pointer; font-size: 16px; font-weight: 700; }
      .icon-button.secondary { background: #eef2f7; color: var(--text); border-color: var(--line); }
      .icon-button.danger { background: var(--danger-ghost); color: var(--danger); border-color: #f4c7c3; }
      table { width: 100%; border-collapse: separate; border-spacing: 0; min-width: 920px; }
      th, td { text-align: left; padding: 9px 8px; border-bottom: 1px solid var(--line); vertical-align: top; }
      th { position: sticky; top: 0; background: var(--surface); font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); z-index: 1; }
      tbody tr:hover { background: rgba(37,99,235,0.03); }
      .table-input { min-width: 110px; }
      .checkbox-cell { width: 48px; text-align: center; }
      .login-shell { min-height: 100vh; display: grid; place-items: center; padding: 24px; }
      .login-card { width: min(420px, 100%); background: var(--surface); border: 1px solid var(--line); border-radius: 20px; padding: 24px; box-shadow: 0 18px 50px rgba(16,24,40,0.12); }
      .login-card h1 { margin-top: 0; margin-bottom: 10px; }
      .login-card p { color: var(--muted); }
      .login-card .field { margin-bottom: 14px; }
      .tag { display: inline-block; padding: 2px 8px; border-radius: 999px; background: #e8f0ff; color: var(--accent); font-size: 12px; font-weight: 600; }
      .spacer { flex: 1; }
      @media (max-width: 1100px) {
        .app-shell { padding-left: 0; }
        .sidebar { position: static; width: auto; border-right: 0; }
        .main { padding-top: 0; }
        .form-grid, .form-grid.wide { grid-template-columns: repeat(2, minmax(150px, 1fr)); }
      }
      @media (max-width: 720px) {
        .main { padding: 16px; }
        .topbar { flex-direction: column; align-items: flex-start; }
        .form-grid, .form-grid.wide { grid-template-columns: 1fr; }
        .toolbar { align-items: flex-start; }
      }
    </style>
  </head>
  <body>
    ${options.activeSection ? `<div class="app-shell">${sidebar}<main class="main">${content.replace('<!--NOTICE-->', `${notice}${error}`).replace('<!--USER-->', userEmail)}</main></div>` : content.replace('<!--NOTICE-->', `${notice}${error}`).replace('<!--USER-->', userEmail)}
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
        <form method="post" action="/admin/login">
          <div class="field">
            <label>Email</label>
            <input name="email" type="email" required />
          </div>
          <div class="field">
            <label>Password</label>
            <input name="password" type="password" required />
          </div>
          <div class="toolbar">
            <span class="subtle">Uses the Strapi admin login endpoint.</span>
            ${iconButton({ label: 'Sign in', symbol: '→' })}
          </div>
        </form>
      </section>
    </main>`,
    { notice, error }
  );
}

function renderSectionShell(title: string, description: string, body: string, options: AdminLayoutOptions): string {
  return renderLayout(
    title,
    `<div class="topbar">
      <div>
        <h1>${escapeHtml(title)}</h1>
        <!--USER-->
      </div>
      <a class="logout" href="/admin/logout">Logout</a>
    </div>
    <!--NOTICE-->
    <section class="content-card">
      <div class="section-header">
        <div>
          <h2>${escapeHtml(title)}</h2>
          <p class="subtle">${escapeHtml(description)}</p>
        </div>
      </div>
      ${body}
    </section>`,
    options
  );
}

function renderEventsPage(options: AdminLayoutOptions): string {
  return renderSectionShell(
    'Manual Event Emit',
    'Publish an event into the configured event bus to exercise the live achievement logic.',
    `<form method="post" action="/admin/events/emit">
      <div class="form-grid wide">
        <div class="field">
          <label>Topic</label>
          <input name="topic" placeholder="flashcard.review" required />
        </div>
        <div class="field">
          <label>Payload JSON</label>
          <textarea name="payload_json" placeholder='{"userid":"8","username":"vivian"}' required></textarea>
        </div>
      </div>
      <div class="toolbar">
        <span class="subtle">The payload is published exactly as entered.</span>
        <div class="toolbar-actions">
          ${iconButton({ label: 'Refresh subscriptions', symbol: '↻', tone: 'secondary', formaction: '/admin/subscriptions/refresh' })}
          ${iconButton({ label: 'Emit event', symbol: '▶' })}
        </div>
      </div>
    </form>`,
    options
  );
}

function renderAchievementsPage(rows: AdminAchievementRow[], options: AdminLayoutOptions): string {
  const bodyRows = rows.map((row) => `
    <tr>
      <form method="post" action="/admin/achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="table-input" name="code" value="${escapeHtml(row.code)}" /></td>
        <td><input class="table-input" name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input class="table-input" name="icon_name" value="${escapeHtml(row.icon_name ?? '')}" /></td>
        <td><input class="table-input" name="points" type="number" value="${row.points}" /></td>
        <td><input class="table-input" name="goal" type="number" value="${row.goal}" /></td>
        <td class="cell-actions">
          ${iconButton({ label: 'Save achievement', symbol: '✓' })}
      </form>
      <form method="post" action="/admin/achievements/${row.id}/delete">
          ${iconButton({ label: 'Delete achievement', symbol: '✕', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Achievements',
    'Manage achievement definitions stored in as_achievements.',
    `<form method="post" action="/admin/achievements/create">
      <div class="toolbar">
        <span class="subtle">Create or edit the event-to-goal definitions used by the service.</span>
        <div class="toolbar-actions">
          ${iconButton({ label: 'Create achievement', symbol: '+' })}
        </div>
      </div>
      <div class="form-grid">
        <div class="field"><label>Code</label><input name="code" required /></div>
        <div class="field"><label>Event Name</label><input name="event_name" required /></div>
        <div class="field"><label>Icon Name</label><input name="icon_name" /></div>
        <div class="field"><label>Points</label><input name="points" type="number" value="1" required /></div>
        <div class="field"><label>Goal</label><input name="goal" type="number" value="1" required /></div>
      </div>
    </form>
    <table>
      <thead><tr><th>ID</th><th>Code</th><th>Event</th><th>Icon</th><th>Points</th><th>Goal</th><th>Actions</th></tr></thead>
      <tbody>${bodyRows}</tbody>
    </table>`,
    options
  );
}

function renderTranslationsPage(rows: AdminTranslationRow[], options: AdminLayoutOptions): string {
  const bodyRows = rows.map((row) => `
    <tr>
      <form method="post" action="/admin/translations/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="table-input" name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input class="table-input" name="locale" value="${escapeHtml(row.locale)}" /></td>
        <td><input class="table-input" name="title" value="${escapeHtml(row.title ?? '')}" /></td>
        <td><textarea name="description">${escapeHtml(row.description ?? '')}</textarea></td>
        <td class="cell-actions">
          ${iconButton({ label: 'Save translation', symbol: '✓' })}
      </form>
      <form method="post" action="/admin/translations/${row.id}/delete">
          ${iconButton({ label: 'Delete translation', symbol: '✕', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Translations',
    'Manage localized title and description rows in as_achievement_translations.',
    `<form method="post" action="/admin/translations/create">
      <div class="toolbar">
        <span class="subtle">Locale fallback behavior is applied at read time by the API.</span>
        <div class="toolbar-actions">
          ${iconButton({ label: 'Create translation', symbol: '+' })}
        </div>
      </div>
      <div class="form-grid">
        <div class="field"><label>Achievement ID</label><input name="achievement_id" type="number" required /></div>
        <div class="field"><label>Locale</label><input name="locale" value="en" required /></div>
        <div class="field"><label>Title</label><input name="title" /></div>
        <div class="field"><label>Description</label><input name="description" /></div>
      </div>
    </form>
    <table>
      <thead><tr><th>ID</th><th>Achievement ID</th><th>Locale</th><th>Title</th><th>Description</th><th>Actions</th></tr></thead>
      <tbody>${bodyRows}</tbody>
    </table>`,
    options
  );
}

function renderEventListsPage(rows: AdminEventListRow[], options: AdminLayoutOptions): string {
  const bodyRows = rows.map((row) => `
    <tr>
      <form method="post" action="/admin/event-lists/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="table-input" name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input class="table-input" name="points" type="number" value="${row.points}" /></td>
        <td class="cell-actions">
          ${iconButton({ label: 'Save event list row', symbol: '✓' })}
      </form>
      <form method="post" action="/admin/event-lists/${row.id}/delete">
          ${iconButton({ label: 'Delete event list row', symbol: '✕', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Event Lists',
    'Manage subscribed event topics in as_event_lists. Changes trigger a subscription refresh.',
    `<form method="post" action="/admin/event-lists/create">
      <div class="toolbar">
        <span class="subtle">Refreshes the live event-bus subscriptions after each change.</span>
        <div class="toolbar-actions">
          ${iconButton({ label: 'Refresh subscriptions', symbol: '↻', tone: 'secondary', formaction: '/admin/subscriptions/refresh' })}
          ${iconButton({ label: 'Create event list row', symbol: '+' })}
        </div>
      </div>
      <div class="form-grid">
        <div class="field"><label>Event Name</label><input name="event_name" required /></div>
        <div class="field"><label>Points</label><input name="points" type="number" value="1" required /></div>
      </div>
    </form>
    <table>
      <thead><tr><th>ID</th><th>Event Name</th><th>Points</th><th>Actions</th></tr></thead>
      <tbody>${bodyRows}</tbody>
    </table>`,
    options
  );
}

function renderUserAchievementsPage(rows: AdminUserAchievementRow[], options: AdminLayoutOptions): string {
  const bodyRows = rows.map((row) => `
    <tr>
      <form method="post" action="/admin/user-achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="table-input" name="userid" value="${escapeHtml(row.userid)}" /></td>
        <td><input class="table-input" name="username" value="${escapeHtml(row.username ?? '')}" /></td>
        <td><input class="table-input" name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input class="table-input" name="progress" type="number" value="${row.progress}" /></td>
        <td class="checkbox-cell"><input name="achieved" type="checkbox" ${row.achieved ? 'checked' : ''} /></td>
        <td><input class="table-input" name="achieved_at" value="${escapeHtml(row.achieved_at ?? '')}" /></td>
        <td class="cell-actions">
          ${iconButton({ label: 'Save user achievement', symbol: '✓' })}
      </form>
      <form method="post" action="/admin/user-achievements/${row.id}/delete">
          ${iconButton({ label: 'Delete user achievement', symbol: '✕', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'User Achievements',
    'Latest 200 rows from as_user_achievements. Querying is by userid; username is display metadata only.',
    `<div class="toolbar">
      <span class="subtle">This section is table-focused by design and does not create rows directly.</span>
      <div class="toolbar-actions">
        <a class="logout" href="/admin/user-achievements" title="Reload page" aria-label="Reload page">↻</a>
      </div>
    </div>
    <table>
      <thead><tr><th>ID</th><th>User ID</th><th>Username</th><th>Achievement ID</th><th>Progress</th><th>Achieved</th><th>Achieved At</th><th>Actions</th></tr></thead>
      <tbody>${bodyRows}</tbody>
    </table>`,
    options
  );
}

interface AdminRouterDependencies {
  authService: AdminAuthService;
  repository: AdminRepository;
  eventBus: EventBus;
  subscriberService: EventSubscriberService;
  logger: Logger;
}

function pageOptions(req: Request, userEmail: string, activeSection: AdminSection): AdminLayoutOptions {
  return {
    notice: typeof req.query.notice === 'string' ? req.query.notice : null,
    error: typeof req.query.error === 'string' ? req.query.error : null,
    userEmail,
    activeSection,
  };
}

export function createAdminRouter(deps: AdminRouterDependencies): Router {
  const router = express.Router();

  router.get('/login', (req, res) => {
    const session = deps.authService.getSession(readSessionId(req));
    if (session) {
      res.redirect(DEFAULT_ADMIN_PATH);
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
      redirectWithNotice(res, DEFAULT_ADMIN_PATH, 'notice', 'Signed in successfully.');
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

  router.get('/', (_req, res) => {
    res.redirect(DEFAULT_ADMIN_PATH);
  });

  router.get('/events', (req, res) => {
    res.type('html').send(renderEventsPage(pageOptions(req, res.locals.adminSession.email, 'events')));
  });

  router.get('/achievements', async (req, res) => {
    try {
      const rows = await deps.repository.listAchievements();
      res.type('html').send(renderAchievementsPage(rows, pageOptions(req, res.locals.adminSession.email, 'achievements')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render achievements admin page');
      redirectWithNotice(res, '/admin/achievements', 'error', 'Failed to load achievements.');
    }
  });

  router.get('/translations', async (req, res) => {
    try {
      const rows = await deps.repository.listTranslations();
      res.type('html').send(renderTranslationsPage(rows, pageOptions(req, res.locals.adminSession.email, 'translations')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render translations admin page');
      redirectWithNotice(res, '/admin/translations', 'error', 'Failed to load translations.');
    }
  });

  router.get('/event-lists', async (req, res) => {
    try {
      const rows = await deps.repository.listEventLists();
      res.type('html').send(renderEventListsPage(rows, pageOptions(req, res.locals.adminSession.email, 'event-lists')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render event lists admin page');
      redirectWithNotice(res, '/admin/event-lists', 'error', 'Failed to load event lists.');
    }
  });

  router.get('/user-achievements', async (req, res) => {
    try {
      const rows = await deps.repository.listUserAchievements();
      res.type('html').send(renderUserAchievementsPage(rows, pageOptions(req, res.locals.adminSession.email, 'user-achievements')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render user achievements admin page');
      redirectWithNotice(res, '/admin/user-achievements', 'error', 'Failed to load user achievements.');
    }
  });

  router.post('/subscriptions/refresh', async (_req, res) => {
    try {
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin/events', 'notice', 'Event subscriptions refreshed.');
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to refresh subscriptions');
      redirectWithNotice(res, '/admin/events', 'error', 'Failed to refresh event subscriptions.');
    }
  });

  router.post('/events/emit', async (req, res) => {
    try {
      const topic = readRequiredString(req.body, 'topic');
      const payloadJson = readRequiredString(req.body, 'payload_json');
      const payload = JSON.parse(payloadJson);
      const ack = await deps.eventBus.publish(topic, payload);
      redirectWithNotice(res, '/admin/events', 'notice', `Event published to ${ack.topic} at ${ack.publishedAt}.`);
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to emit manual event');
      redirectWithNotice(res, '/admin/events', 'error', error instanceof Error ? error.message : 'Failed to emit event.');
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
      redirectWithNotice(res, '/admin/achievements', 'notice', 'Achievement created.');
    } catch (error) {
      redirectWithNotice(res, '/admin/achievements', 'error', error instanceof Error ? error.message : 'Failed to create achievement.');
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
      redirectWithNotice(res, '/admin/achievements', 'notice', 'Achievement updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin/achievements', 'error', error instanceof Error ? error.message : 'Failed to update achievement.');
    }
  });

  router.post('/achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteAchievement(Number(req.params.id));
      redirectWithNotice(res, '/admin/achievements', 'notice', 'Achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin/achievements', 'error', error instanceof Error ? error.message : 'Failed to delete achievement.');
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
      redirectWithNotice(res, '/admin/translations', 'notice', 'Translation created.');
    } catch (error) {
      redirectWithNotice(res, '/admin/translations', 'error', error instanceof Error ? error.message : 'Failed to create translation.');
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
      redirectWithNotice(res, '/admin/translations', 'notice', 'Translation updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin/translations', 'error', error instanceof Error ? error.message : 'Failed to update translation.');
    }
  });

  router.post('/translations/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteTranslation(Number(req.params.id));
      redirectWithNotice(res, '/admin/translations', 'notice', 'Translation deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin/translations', 'error', error instanceof Error ? error.message : 'Failed to delete translation.');
    }
  });

  router.post('/event-lists/create', async (req, res) => {
    try {
      await deps.repository.createEventList({
        event_name: readRequiredString(req.body, 'event_name'),
        points: readRequiredNumber(req.body, 'points'),
      });
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin/event-lists', 'notice', 'Event list row created and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin/event-lists', 'error', error instanceof Error ? error.message : 'Failed to create event list row.');
    }
  });

  router.post('/event-lists/:id/update', async (req, res) => {
    try {
      await deps.repository.updateEventList(Number(req.params.id), {
        event_name: readRequiredString(req.body, 'event_name'),
        points: readRequiredNumber(req.body, 'points'),
      });
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin/event-lists', 'notice', 'Event list row updated and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin/event-lists', 'error', error instanceof Error ? error.message : 'Failed to update event list row.');
    }
  });

  router.post('/event-lists/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteEventList(Number(req.params.id));
      await deps.subscriberService.refresh();
      redirectWithNotice(res, '/admin/event-lists', 'notice', 'Event list row deleted and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, '/admin/event-lists', 'error', error instanceof Error ? error.message : 'Failed to delete event list row.');
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
      redirectWithNotice(res, '/admin/user-achievements', 'notice', 'User achievement updated.');
    } catch (error) {
      redirectWithNotice(res, '/admin/user-achievements', 'error', error instanceof Error ? error.message : 'Failed to update user achievement.');
    }
  });

  router.post('/user-achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteUserAchievement(Number(req.params.id));
      redirectWithNotice(res, '/admin/user-achievements', 'notice', 'User achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, '/admin/user-achievements', 'error', error instanceof Error ? error.message : 'Failed to delete user achievement.');
    }
  });

  return router;
}
