import type { Request, Response, Router } from 'express';
import express from 'express';
import crypto from 'node:crypto';
import type { Logger } from 'pino';
import type { EventBus } from '../types';
import {
  AdminRepository,
  type AdminAchievementRow,
  type AdminAchievementChangeLogRow,
  type AdminDashboardData,
  type AdminEventListRow,
  type AdminEventLogRow,
  type AdminPageQuery,
  type AdminPageResult,
  type AdminTranslationRow,
  type AdminUserAchievementRow,
} from '../repositories/adminRepository';
import { AdminAuthService } from '../services/adminAuthService';
import { AchievementService } from '../services/achievementService';
import { EventSubscriberService } from '../services/eventSubscriberService';
import { registerApiRoutes } from '../api/v1/routes';

const SESSION_COOKIE = 'achievement_admin_session';
const DEFAULT_ADMIN_PATH = '/admin/dashboard';
const DEFAULT_PAGE_SIZE = 20;

type AdminSection = 'dashboard' | 'events' | 'api-docs' | 'achievements' | 'translations' | 'event-lists' | 'user-achievements' | 'event-logs' | 'change-logs';

interface AdminLayoutOptions {
  notice?: string | null;
  error?: string | null;
  userEmail?: string | null;
  activeSection?: AdminSection;
}

interface AdminEventTestState {
  eventLogs: AdminEventLogRow[];
  userAchievements: AdminUserAchievementRow[];
  changeLogs: AdminAchievementChangeLogRow[];
  counts: Array<{ label: string; count: number }>;
}

interface PageState {
  page: number;
  pageSize: number;
  whereClause: string;
}

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function serializeForInlineScript(value: unknown): string {
  return JSON.stringify(value)
    .replace(/</g, '\\u003c')
    .replace(/>/g, '\\u003e')
    .replace(/&/g, '\\u0026')
    .replace(/\u2028/g, '\\u2028')
    .replace(/\u2029/g, '\\u2029');
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
    cookies[pair.slice(0, index).trim()] = decodeURIComponent(pair.slice(index + 1).trim());
    return cookies;
  }, {});
}

function setSessionCookie(res: Response, sessionId: string): void {
  res.setHeader('Set-Cookie', `${SESSION_COOKIE}=${encodeURIComponent(sessionId)}; Path=/; HttpOnly; SameSite=Lax`);
}

function clearSessionCookie(res: Response): void {
  res.setHeader('Set-Cookie', `${SESSION_COOKIE}=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0`);
}

function readSessionId(req: Request): string | null {
  return parseCookies(req)[SESSION_COOKIE] ?? null;
}

function redirectWithNotice(res: Response, path: string, type: 'notice' | 'error', message: string): void {
  const url = new URL(`http://local${path}`);
  url.searchParams.set(type, message);
  res.redirect(url.pathname + url.search);
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
  const value = Number(readRequiredString(body, field));
  if (!Number.isFinite(value)) {
    throw new Error(`Invalid number for "${field}".`);
  }
  return value;
}

function readBoolean(body: unknown, field: string): boolean {
  const value = typeof body === 'object' && body !== null ? (body as Record<string, unknown>)[field] : undefined;
  return value === 'true' || value === 'on' || value === true;
}

function readPageState(req: Request): PageState {
  const page = Number(typeof req.query.page === 'string' ? req.query.page : '1');
  const pageSize = Number(typeof req.query.pageSize === 'string' ? req.query.pageSize : String(DEFAULT_PAGE_SIZE));
  return {
    page: Number.isFinite(page) && page > 0 ? Math.floor(page) : 1,
    pageSize: Number.isFinite(pageSize) && pageSize > 0 ? Math.floor(pageSize) : DEFAULT_PAGE_SIZE,
    whereClause: typeof req.query.where === 'string' ? req.query.where : '',
  };
}

function pageQuery(state: PageState): AdminPageQuery {
  return {
    page: state.page,
    pageSize: state.pageSize,
    whereClause: state.whereClause.trim() === '' ? null : state.whereClause.trim(),
  };
}

function buildSectionUrl(path: string, state: PageState, overrides: Partial<PageState> = {}): string {
  const url = new URL(`http://local${path}`);
  const next = {
    page: overrides.page ?? state.page,
    pageSize: overrides.pageSize ?? state.pageSize,
    whereClause: overrides.whereClause ?? state.whereClause,
  };
  url.searchParams.set('page', String(next.page));
  url.searchParams.set('pageSize', String(next.pageSize));
  if (next.whereClause.trim() !== '') {
    url.searchParams.set('where', next.whereClause);
  }
  return url.pathname + url.search;
}

function pagination(total: number, state: PageState, path: string): string {
  const totalPages = Math.max(1, Math.ceil(total / state.pageSize));
  const current = Math.min(state.page, totalPages);
  const items: string[] = [];
  const pages = new Set<number>([1, totalPages, current - 1, current, current + 1].filter((value) => value >= 1 && value <= totalPages));
  const ordered = Array.from(pages).sort((left, right) => left - right);

  const link = (page: number, label: string, disabled = false, active = false) =>
    `<li class="page-item${disabled ? ' disabled' : ''}${active ? ' active' : ''}">
      <a class="page-link" href="${disabled ? '#' : escapeHtml(buildSectionUrl(path, state, { page }))}">${escapeHtml(label)}</a>
    </li>`;

  items.push(link(Math.max(1, current - 1), 'Previous', current === 1));
  let previous = 0;
  for (const page of ordered) {
    if (previous !== 0 && page - previous > 1) {
      items.push('<li class="page-item disabled"><span class="page-link">…</span></li>');
    }
    items.push(link(page, String(page), false, page === current));
    previous = page;
  }
  items.push(link(Math.min(totalPages, current + 1), 'Next', current === totalPages));

  return `<nav aria-label="Pagination"><ul class="pagination pagination-sm mb-0">${items.join('')}</ul></nav>`;
}

function navLink(section: AdminSection, href: string, label: string, activeSection?: AdminSection): string {
  return `<a class="sidebar-link ${activeSection === section ? 'active' : ''}" href="${href}" aria-current="${activeSection === section ? 'page' : 'false'}">${escapeHtml(label)}</a>`;
}

function iconButton(options: { label: string; icon: string; tone?: 'primary' | 'secondary' | 'danger'; formaction?: string; type?: 'submit' | 'button' }): string {
  const toneClass =
    options.tone === 'danger' ? 'btn-outline-danger' :
    options.tone === 'secondary' ? 'btn-outline-secondary' :
    'btn-primary';
  const formaction = options.formaction ? ` formaction="${escapeHtml(options.formaction)}"` : '';
  return `<button type="${options.type ?? 'submit'}" class="btn btn-sm ${toneClass}" title="${escapeHtml(options.label)}" aria-label="${escapeHtml(options.label)}"${formaction}><i class="bi bi-${escapeHtml(options.icon)}"></i></button>`;
}

function normalizeManualEventPayload(topic: string, payload: Record<string, unknown>): Record<string, unknown> {
  return {
    ...payload,
    event_id: payload.event_id ?? crypto.randomUUID(),
    event_name: payload.event_name ?? topic,
    userid: payload.userid ?? null,
    username: payload.username ?? null,
  };
}

async function captureEventTestState(
  repository: AdminRepository,
  userid: string | null
): Promise<AdminEventTestState> {
  const userWhere = userid ? `userid = '${escapeSqlLiteral(userid)}'` : null;
  const [eventLogs, userAchievements, changeLogs] = await Promise.all([
    repository.listEventLogs({ page: 1, pageSize: 1, whereClause: userWhere }),
    repository.listUserAchievements({ page: 1, pageSize: 1, whereClause: userWhere }),
    repository.listAchievementChangeLogs({ page: 1, pageSize: 1, whereClause: userWhere }),
  ]);

  return {
    eventLogs: eventLogs.rows,
    userAchievements: userAchievements.rows,
    changeLogs: changeLogs.rows,
    counts: [
      { label: 'Event Logs', count: eventLogs.total },
      { label: 'User Achievements', count: userAchievements.total },
      { label: 'Change Logs', count: changeLogs.total },
    ],
  };
}

function renderLayout(title: string, content: string, options: AdminLayoutOptions = {}): string {
  const notice = options.notice ? `<div class="alert alert-success" role="alert">${escapeHtml(options.notice)}</div>` : '';
  const error = options.error ? `<div class="alert alert-danger" role="alert">${escapeHtml(options.error)}</div>` : '';
  const sidebar = options.activeSection ? `
    <aside class="sidebar">
      <div class="sidebar-group-label">Actions</div>
      <nav class="sidebar-nav">
          ${navLink('dashboard', '/admin/dashboard', 'Dashboard', options.activeSection)}
          ${navLink('events', '/admin/events', 'Manual Event Emit', options.activeSection)}
          ${navLink('api-docs', '/admin/api-docs', 'API Docs', options.activeSection)}
      </nav>
      <div class="sidebar-group-label">Entities</div>
      <nav class="sidebar-nav">
          ${navLink('achievements', '/admin/achievements', 'Achievements', options.activeSection)}
          ${navLink('translations', '/admin/translations', 'Translations', options.activeSection)}
          ${navLink('event-lists', '/admin/event-lists', 'Event Lists', options.activeSection)}
          ${navLink('user-achievements', '/admin/user-achievements', 'User Achievements', options.activeSection)}
          ${navLink('event-logs', '/admin/event-logs', 'Event Logs', options.activeSection)}
          ${navLink('change-logs', '/admin/change-logs', 'Change Logs', options.activeSection)}
      </nav>
    </aside>` : '';

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${escapeHtml(title)}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
      * { box-sizing: border-box; }
      body { margin: 0; background: #f4f6f8; color: #222; }
      .top-banner { height: 64px; background: #1f2937; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; position: sticky; top: 0; z-index: 10; }
      .topbar-brand { font-size: 20px; font-weight: 700; letter-spacing: 0.01em; }
      .top-banner-right { display: flex; align-items: center; gap: 20px; color: #d1d5db; font-size: 14px; }
      .top-banner-right a { color: #d1d5db; text-decoration: none; }
      .top-banner-right a:hover { color: #fff; }
      .admin-shell { display: flex; height: calc(100vh - 64px); overflow: hidden; }
      .sidebar { width: 220px; background: #111827; color: #fff; padding: 20px 0; flex-shrink: 0; overflow-y: auto; }
      .sidebar-group-label { padding: 0 24px; margin: 0 0 10px; color: #9ca3af; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; }
      .sidebar-nav { display: block; margin-bottom: 18px; }
      .sidebar-link { display: block; color: #d1d5db; text-decoration: none; padding: 12px 24px; font-size: 15px; }
      .sidebar-link:hover, .sidebar-link.active { background: #374151; color: #fff; }
      .content { flex: 1; padding: 24px; min-width: 0; overflow-y: auto; }
      .card { background: #fff; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08); padding: 20px; border: 0; }
      .card-body { padding: 0; }
      .table-wrapper { width: 100%; overflow-x: auto; border: 1px solid #e5e7eb; border-radius: 8px; }
      .table-wrapper table { width: max-content; min-width: 100%; border-collapse: collapse; background: #fff; margin: 0; }
      .table-wrapper th, .table-wrapper td { padding: 12px 16px; border-bottom: 1px solid #e5e7eb; text-align: left; white-space: nowrap; font-size: 14px; vertical-align: top; background: #fff; }
      .table-wrapper th { background: #f9fafb; font-weight: 700; color: #374151; position: sticky; top: 0; z-index: 1; }
      .table-wrapper tbody tr:hover td { background: #f9fafb; }
      .card-header-inline { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; gap: 16px; }
      .where-help code { white-space: nowrap; }
      @media (max-width: 768px) {
        .admin-shell { flex-direction: column; height: auto; overflow: visible; }
        .sidebar { width: 100%; display: flex; overflow-x: auto; overflow-y: visible; padding: 0; }
        .sidebar-group-label { display: none; }
        .sidebar-nav { display: flex; margin: 0; }
        .sidebar-link { white-space: nowrap; }
        .content { padding: 16px; overflow-y: visible; }
      }
    </style>
  </head>
  <body>
    <header class="top-banner">
      <span class="topbar-brand">LangGo Achievement Admin</span>
      ${options.userEmail ? `<div class="top-banner-right"><span>${escapeHtml(options.userEmail)}</span><a href="/admin/logout">Logout</a></div>` : ''}
    </header>
    ${notice || error ? `<div class="content pb-0">${notice}${error}</div>` : ''}
    <div class="admin-shell">
      ${options.activeSection ? sidebar : ''}
      <main class="content">${content.replace('<!--NOTICE-->', '').replace('<!--USER-->', '')}</main>
    </div>
  </body>
</html>`;
}

function renderLoginPage(strapiLoginUrl: string, notice?: string | null, error?: string | null): string {
  return renderLayout(
    'Achievement Admin Login',
    `<div class="container py-5">
      <div class="row justify-content-center">
        <div class="col-12 col-md-6 col-lg-5">
          <div class="card shadow-sm border-0">
            <div class="card-body p-4">
              <span class="badge text-bg-primary-subtle text-primary-emphasis mb-3">Strapi-backed auth</span>
              <h1 class="h3 mb-2">Achievement Admin</h1>
              <p class="text-secondary">Authenticate with the Strapi admin account at <a href="${escapeHtml(strapiLoginUrl)}" target="_blank" rel="noreferrer">${escapeHtml(strapiLoginUrl)}</a>.</p>
              <p class="text-secondary small mb-3">Only Strapi users with an admin role can access this UI.</p>
              <!--NOTICE-->
              <form method="post" action="/admin/login" class="vstack gap-3">
                <div>
                  <label class="form-label">Email</label>
                  <input class="form-control" name="email" type="email" required />
                </div>
                <div>
                  <label class="form-label">Password</label>
                  <input class="form-control" name="password" type="password" required />
                </div>
                <div class="d-flex justify-content-end">
                  ${iconButton({ label: 'Sign in', icon: 'box-arrow-in-right' })}
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>`,
    { notice, error }
  );
}

function renderSectionShell(title: string, description: string, body: string, options: AdminLayoutOptions): string {
  return renderLayout(
    title,
    `<div class="card-header-inline">
      <div>
        <h1 class="h3 mb-1">${escapeHtml(title)}</h1>
        <p class="text-secondary mb-0">${escapeHtml(description)}</p>
      </div>
    </div>
    <!--NOTICE-->
    <div class="card">
      <div class="card-body">
        ${body}
      </div>
    </div>`,
    options
  );
}

function buildOpenApiDocument(): Record<string, unknown> {
  return {
    openapi: '3.0.3',
    info: {
      title: 'LangGo Achievement Server API',
      version: '0.1.0',
      description: 'Interactive admin-authenticated API documentation for the exposed achievement endpoints.',
    },
    servers: [
      {
        url: '/admin/api-docs/proxy',
        description: 'Admin-authenticated proxy for Swagger Try it out',
      },
    ],
    tags: [
      { name: 'Health' },
      { name: 'Achievements' },
    ],
    paths: {
      '/api/v1/healthz': {
        get: {
          tags: ['Health'],
          summary: 'Health check',
          responses: {
            '200': {
              description: 'OK',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      ok: { type: 'boolean', example: true },
                    },
                    required: ['ok'],
                  },
                },
              },
            },
          },
        },
      },
      '/api/v1/achievements-achieved': {
        get: {
          tags: ['Achievements'],
          summary: 'List achieved achievements for the caller',
          description: 'Provide `x-user-id` in the Swagger UI headers before running the call.',
          parameters: [
            {
              name: 'locale',
              in: 'query',
              required: false,
              schema: { type: 'string', default: 'en' },
            },
            {
              name: 'x-user-id',
              in: 'header',
              required: true,
              schema: { type: 'string' },
            },
          ],
          responses: {
            '200': {
              description: 'Achievement rows',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      data: {
                        type: 'array',
                        items: { type: 'object', additionalProperties: true },
                      },
                    },
                    required: ['data'],
                  },
                },
              },
            },
          },
        },
      },
      '/api/v1/achievements-not-achieved': {
        get: {
          tags: ['Achievements'],
          summary: 'List not-yet-achieved achievements for the caller',
          description: 'Provide `x-user-id` in the Swagger UI headers before running the call.',
          parameters: [
            {
              name: 'locale',
              in: 'query',
              required: false,
              schema: { type: 'string', default: 'en' },
            },
            {
              name: 'x-user-id',
              in: 'header',
              required: true,
              schema: { type: 'string' },
            },
          ],
          responses: {
            '200': {
              description: 'Achievement rows',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      data: {
                        type: 'array',
                        items: { type: 'object', additionalProperties: true },
                      },
                    },
                    required: ['data'],
                  },
                },
              },
            },
          },
        },
      },
    },
  };
}

function renderSwaggerPage(options: AdminLayoutOptions): string {
  return renderSectionShell(
    'API Docs',
    'Swagger UI for the exposed achievement endpoints. Requests run through an admin-authenticated proxy so the internal key stays server-side.',
    `<p class="small text-secondary mb-3">For the caller-scoped endpoints, fill in <code>x-user-id</code> in the request headers before running the call.</p>
    <div id="swagger-ui"></div>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
    <style>
      .swagger-ui .topbar { display: none; }
      .swagger-ui .opblock-tag { border-bottom: 1px solid #e5e7eb; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      window.ui = SwaggerUIBundle({
        url: '/admin/api-docs/openapi.json',
        dom_id: '#swagger-ui',
        deepLinking: true,
        displayRequestDuration: true,
        persistAuthorization: false,
      });
    </script>`,
    { ...options, activeSection: 'api-docs' }
  );
}

function renderNewRecordPage(
  title: string,
  description: string,
  backHref: string,
  fieldsHtml: string,
  formAction: string,
  options: AdminLayoutOptions
): string {
  return renderSectionShell(
    title,
    description,
    `<form method="post" action="${formAction}" class="vstack gap-3">
      <div class="d-flex justify-content-between align-items-center">
        <a class="btn btn-sm btn-outline-secondary" href="${backHref}"><i class="bi bi-arrow-left"></i></a>
        ${iconButton({ label: 'Create record', icon: 'plus-lg' })}
      </div>
      <div class="row g-3">
        ${fieldsHtml}
      </div>
    </form>`,
    options
  );
}

function renderFilterToolbar(path: string, state: PageState, total: number): string {
  return `
    <form method="get" action="${path}" class="mb-3">
      <div class="d-flex flex-column gap-3">
        <div class="d-flex flex-wrap align-items-center gap-2">
          <label class="form-label mb-0 fw-semibold">Optional SQL sub-clause appended after <code>WHERE</code>.</label>
          <input class="form-control form-control-sm font-monospace flex-grow-1" style="min-width: 320px;" name="where" value="${escapeHtml(state.whereClause)}" placeholder="e.g. event_name = 'flashcard.create' AND points >= 1" />
          <input type="hidden" name="page" value="1" />
          <button type="submit" class="btn btn-primary btn-sm">Apply</button>
        </div>
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
          <div class="d-flex flex-wrap align-items-center gap-4">
            <div class="small text-secondary">
              <span class="fw-semibold text-dark">Total Rows:</span> ${total}
            </div>
            <div class="d-flex align-items-center gap-2">
              <label class="form-label mb-0 fw-semibold">PageSize</label>
              <input class="form-control form-control-sm" style="width: 88px;" name="pageSize" type="number" min="1" max="100" value="${state.pageSize}" />
              <button type="submit" class="btn btn-outline-secondary btn-sm" title="Apply page size" aria-label="Apply page size">
                <i class="bi bi-check-lg"></i>
              </button>
              <a class="btn btn-outline-secondary btn-sm" href="${path}" title="Reset filters" aria-label="Reset filters">
                <i class="bi bi-arrow-clockwise"></i>
              </a>
            </div>
          </div>
          <div class="d-flex align-items-center">
            ${pagination(total, state, path)}
          </div>
        </div>
      </div>
    </form>`;
}

function wait(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function escapeSqlLiteral(value: string): string {
  return value.replaceAll("'", "''");
}

function renderStateBlock(title: string, rows: unknown[]): string {
  return `
    <div class="col-12 col-xl-4">
      <div class="card border-0 shadow-sm h-100">
        <div class="card-body">
          <h3 class="h6">${escapeHtml(title)}</h3>
          <pre class="small font-monospace mb-0">${escapeHtml(JSON.stringify(rows, null, 2))}</pre>
        </div>
      </div>
    </div>`;
}

function renderCountDiff(before: AdminEventTestState, after: AdminEventTestState): string {
  const rows = after.counts.map((entry, index) => {
    const previous = before.counts[index]?.count ?? 0;
    const delta = entry.count - previous;
    return `<tr>
      <td>${escapeHtml(entry.label)}</td>
      <td>${previous}</td>
      <td>${entry.count}</td>
      <td class="${delta === 0 ? 'text-secondary' : delta > 0 ? 'text-success' : 'text-danger'}">${delta >= 0 ? '+' : ''}${delta}</td>
    </tr>`;
  }).join('');

  return `
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-body">
        <h2 class="h5 mb-3">Entity Count Changes</h2>
        <div class="table-responsive">
          <table class="table table-sm mb-0">
            <thead><tr><th>Entity</th><th>Before</th><th>After</th><th>Delta</th></tr></thead>
            <tbody>${rows}</tbody>
          </table>
        </div>
      </div>
    </div>`;
}

function buildAchievementEventPresetScript(eventNames: string[]): string {
  return `
const buildAchievementEventPresets = () => {
  const userid = '8';
  const username = 'vivian';
  const eventNames = ${JSON.stringify(eventNames)};
  return Object.fromEntries(eventNames.map((eventName) => [eventName, {
    event_name: eventName,
    userid,
    username
  }]));
};
const achievementTopicEl = document.getElementById('achievement-event-topic');
const achievementPayloadEl = document.getElementById('achievement-event-payload');
const loadAchievementPreset = () => {
  const presets = buildAchievementEventPresets();
  const next = presets[achievementTopicEl.value];
  if (next) {
    achievementPayloadEl.value = JSON.stringify(next, null, 2);
  }
};
achievementTopicEl?.addEventListener('change', loadAchievementPreset);
if (achievementTopicEl && achievementPayloadEl && achievementPayloadEl.value.trim() === '') {
  loadAchievementPreset();
}
`;
}

function renderEventsPage(
  options: AdminLayoutOptions,
  eventNames: string[],
  payloadText = '',
  result: {
    topic: string;
    ack: Record<string, unknown> | null;
    before: AdminEventTestState;
    after: AdminEventTestState;
  } | null = null
): string {
  const selectedTopic = result?.topic ?? eventNames[0] ?? '';
  const topicOptions = eventNames.map((eventName) => `<option value="${escapeHtml(eventName)}" ${selectedTopic === eventName ? 'selected' : ''}>${escapeHtml(eventName)}</option>`).join('');
  const changesSection = result ? `
    <div class="mt-4">
      <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
          <h2 class="h5 mb-3">Emit Result</h2>
          <dl class="row mb-0 small">
            <dt class="col-sm-3">Topic</dt><dd class="col-sm-9 font-monospace">${escapeHtml(result.topic)}</dd>
            <dt class="col-sm-3">Publish Ack</dt><dd class="col-sm-9"><pre class="small font-monospace mb-0">${escapeHtml(JSON.stringify(result.ack, null, 2))}</pre></dd>
          </dl>
        </div>
      </div>
      ${renderCountDiff(result.before, result.after)}
      <div class="row g-3">
        ${renderStateBlock('Event Logs Before', result.before.eventLogs)}
        ${renderStateBlock('Event Logs After', result.after.eventLogs)}
        ${renderStateBlock('User Achievements Before', result.before.userAchievements)}
        ${renderStateBlock('User Achievements After', result.after.userAchievements)}
        ${renderStateBlock('Change Logs Before', result.before.changeLogs)}
        ${renderStateBlock('Change Logs After', result.after.changeLogs)}
      </div>
    </div>` : '';

  return renderSectionShell(
    'Manual Event Emit',
    'Publish an event into the configured event bus to exercise the live achievement logic.',
    `<div class="row g-4">
      <div class="col-12">
        <form method="post" action="/admin/events/emit" class="row g-3">
          <div class="col-12 col-lg-4">
            <label class="form-label fw-semibold">Topic</label>
            <select class="form-select form-select-sm font-monospace" id="achievement-event-topic" name="topic">
              ${topicOptions}
            </select>
            <div class="form-text">Achievement manual emit uses the simple payload schema: <code>event_name</code>, <code>userid</code>, and <code>username</code>.</div>
          </div>
          <div class="col-12">
            <label class="form-label fw-semibold">Payload JSON</label>
            <textarea class="form-control form-control-sm font-monospace" id="achievement-event-payload" name="payload_json" rows="14" placeholder='{"userid":"8","username":"vivian","event_name":"flashcard.review"}' required>${escapeHtml(payloadText)}</textarea>
          </div>
          <div class="col-12 d-flex justify-content-end gap-2">
            <button type="submit" formaction="/admin/subscriptions/refresh" class="btn btn-outline-secondary btn-sm" title="Refresh subscriptions" aria-label="Refresh subscriptions">
              <i class="bi bi-arrow-clockwise"></i>
            </button>
            <button type="button" class="btn btn-outline-secondary btn-sm" title="Clear payload" aria-label="Clear payload" onclick="document.getElementById('achievement-event-payload').value='';">
              <i class="bi bi-eraser"></i>
            </button>
            <button type="submit" class="btn btn-primary btn-sm" title="Emit event" aria-label="Emit event">
              <i class="bi bi-send-fill"></i>
            </button>
          </div>
        </form>
      </div>
    </div>
    ${changesSection}
    <script>${buildAchievementEventPresetScript(eventNames)}</script>`,
    options
  );
}

function renderDashboardPage(options: AdminLayoutOptions, data: AdminDashboardData): string {
  const totals = [
    { label: 'Event Logs', value: data.totals.events, tone: 'text-primary' },
    { label: 'Users', value: data.totals.users, tone: 'text-success' },
    { label: 'User Achievements', value: data.totals.userAchievements, tone: 'text-warning' },
    { label: 'Achievements', value: data.totals.achievementDefinitions, tone: 'text-danger' },
  ];

  const cards = totals.map((item) => `
    <div class="col-12 col-md-6 col-xl-3">
      <div class="card border-0 shadow-sm h-100">
        <div class="card-body">
          <div class="text-secondary small text-uppercase fw-semibold mb-2">${escapeHtml(item.label)}</div>
          <div class="fs-2 fw-bold ${item.tone}">${item.value}</div>
        </div>
      </div>
    </div>`).join('');

  const topUserRows = data.topUsers.map((row, index) => `
    <tr>
      <td>${index + 1}</td>
      <td>${escapeHtml(row.userid)}</td>
      <td>${escapeHtml(row.username ?? '')}</td>
      <td>${row.count}</td>
    </tr>`).join('');

  const chartData = serializeForInlineScript(data);

  return renderLayout(
    'Dashboard',
    `<div class="card-header-inline">
      <div>
        <h1 class="h3 mb-1">Dashboard</h1>
        <p class="text-secondary mb-0">Achievement event activity overview from the live service.</p>
      </div>
    </div>
    <div class="row g-3 mb-4">
      ${cards}
    </div>
    <div class="row g-4">
      <div class="col-12">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h2 class="h5 mb-1">Event Graph</h2>
            <p class="text-secondary small mb-3">X-axis: date. Y-axis: event count. Window: up to 120 days.</p>
            <canvas id="daily-events-chart" height="60"></canvas>
          </div>
        </div>
      </div>
      <div class="col-12 col-xl-7">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h2 class="h5 mb-3">Events by Type</h2>
            <div class="table-responsive">
              <table class="table table-sm mb-0">
                <thead><tr><th>Event Name</th><th>Count</th></tr></thead>
                <tbody>
                  ${data.eventTypeCounts.map((row) => `
                    <tr>
                      <td class="font-monospace">${escapeHtml(row.event_name)}</td>
                      <td>${row.count}</td>
                    </tr>`).join('') || '<tr><td colspan="2" class="text-secondary">No data</td></tr>'}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <div class="col-12 col-xl-5">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h2 class="h5 mb-3">Top Users by Event Count</h2>
            <div class="table-responsive">
              <table class="table table-sm mb-0">
                <thead><tr><th>#</th><th>User ID</th><th>Username</th><th>Events</th></tr></thead>
                <tbody>${topUserRows || '<tr><td colspan="4" class="text-secondary">No data</td></tr>'}</tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
    <script>
      const dashboardData = ${chartData};
      const chartFontColor = '#374151';
      const gridColor = 'rgba(209, 213, 219, 0.7)';

      const buildLineChart = (id, labels, values, label, color) => {
        const el = document.getElementById(id);
        if (!el) return;
        new Chart(el, {
          type: 'line',
          data: {
            labels,
            datasets: [{
              label,
              data: values,
              borderColor: color,
              backgroundColor: color + '22',
              fill: true,
              tension: 0.25,
            }]
          },
          options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
              x: { ticks: { color: chartFontColor }, grid: { color: gridColor } },
              y: { beginAtZero: true, ticks: { color: chartFontColor }, grid: { color: gridColor } }
            }
          }
        });
      };

      buildLineChart(
        'daily-events-chart',
        dashboardData.dailyEvents.map((row) => row.day),
        dashboardData.dailyEvents.map((row) => row.count),
        'Events',
        '#2563eb'
      );
    </script>`,
    options
  );
}

function renderAchievementsPage(result: AdminPageResult<AdminAchievementRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <form method="post" action="/admin/achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="form-control form-control-sm font-monospace" name="code" value="${escapeHtml(row.code)}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="icon_name" value="${escapeHtml(row.icon_name ?? '')}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="points" type="number" value="${row.points}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="goal" type="number" value="${row.goal}" /></td>
        <td class="text-nowrap d-flex gap-2">
          ${iconButton({ label: 'Save achievement', icon: 'floppy' })}
      </form>
      <form method="post" action="/admin/achievements/${row.id}/delete">
          ${iconButton({ label: 'Delete achievement', icon: 'trash', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Achievements',
    'Manage achievement definitions stored in as_achievements.',
    `<div class="d-flex justify-content-end mb-3">
      <a class="btn btn-sm btn-primary" href="/admin/achievements/new" title="Add achievement" aria-label="Add achievement"><i class="bi bi-plus-lg"></i></a>
    </div>
    ${renderFilterToolbar('/admin/achievements', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>code</th><th>event_name</th><th>icon_name</th><th>points</th><th>goal</th><th>actions</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderTranslationsPage(result: AdminPageResult<AdminTranslationRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <form method="post" action="/admin/translations/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="form-control form-control-sm font-monospace" name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="locale" value="${escapeHtml(row.locale)}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="title" value="${escapeHtml(row.title ?? '')}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="description" value="${escapeHtml(row.description ?? '')}" /></td>
        <td class="text-nowrap d-flex gap-2">
          ${iconButton({ label: 'Save translation', icon: 'floppy' })}
      </form>
      <form method="post" action="/admin/translations/${row.id}/delete">
          ${iconButton({ label: 'Delete translation', icon: 'trash', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Translations',
    'Manage localized rows stored in as_achievement_translations.',
    `<div class="d-flex justify-content-end mb-3">
      <a class="btn btn-sm btn-primary" href="/admin/translations/new" title="Add translation" aria-label="Add translation"><i class="bi bi-plus-lg"></i></a>
    </div>
    ${renderFilterToolbar('/admin/translations', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>achievement_id</th><th>locale</th><th>title</th><th>description</th><th>actions</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderEventListsPage(result: AdminPageResult<AdminEventListRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <form method="post" action="/admin/event-lists/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="form-control form-control-sm font-monospace" name="event_name" value="${escapeHtml(row.event_name)}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="points" type="number" value="${row.points}" /></td>
        <td class="text-nowrap d-flex gap-2">
          ${iconButton({ label: 'Save event list row', icon: 'floppy' })}
      </form>
      <form method="post" action="/admin/event-lists/${row.id}/delete">
          ${iconButton({ label: 'Delete event list row', icon: 'trash', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'Event Lists',
    'Manage subscribed topics stored in as_event_lists.',
    `<div class="d-flex justify-content-end gap-2 mb-3">
      <form method="post" action="/admin/subscriptions/refresh" class="m-0">
        ${iconButton({ label: 'Refresh subscriptions', icon: 'arrow-clockwise', tone: 'secondary' })}
      </form>
      <a class="btn btn-sm btn-primary" href="/admin/event-lists/new" title="Add event list row" aria-label="Add event list row"><i class="bi bi-plus-lg"></i></a>
    </div>
    ${renderFilterToolbar('/admin/event-lists', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>event_name</th><th>points</th><th>actions</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderUserAchievementsPage(result: AdminPageResult<AdminUserAchievementRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <form method="post" action="/admin/user-achievements/${row.id}/update">
        <td>${row.id}</td>
        <td><input class="form-control form-control-sm font-monospace" name="userid" value="${escapeHtml(row.userid)}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="username" value="${escapeHtml(row.username ?? '')}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="achievement_id" type="number" value="${row.achievement_id}" /></td>
        <td><input class="form-control form-control-sm font-monospace" name="progress" type="number" value="${row.progress}" /></td>
        <td><input class="form-check-input" name="achieved" type="checkbox" ${row.achieved ? 'checked' : ''} /></td>
        <td><input class="form-control form-control-sm font-monospace" name="achieved_at" value="${escapeHtml(row.achieved_at ?? '')}" /></td>
        <td class="text-nowrap d-flex gap-2">
          ${iconButton({ label: 'Save user achievement', icon: 'floppy' })}
      </form>
      <form method="post" action="/admin/user-achievements/${row.id}/delete">
          ${iconButton({ label: 'Delete user achievement', icon: 'trash', tone: 'danger' })}
      </form>
        </td>
    </tr>`).join('');

  return renderSectionShell(
    'User Achievements',
    'Query and edit rows stored in as_user_achievements.',
    `${renderFilterToolbar('/admin/user-achievements', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>userid</th><th>username</th><th>achievement_id</th><th>progress</th><th>achieved</th><th>achieved_at</th><th>actions</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderEventLogsPage(result: AdminPageResult<AdminEventLogRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <td>${row.id}</td>
      <td class="font-monospace">${escapeHtml(row.event_name)}</td>
      <td class="font-monospace">${escapeHtml(row.userid ?? '')}</td>
      <td class="font-monospace">${escapeHtml(row.username ?? '')}</td>
      <td>${escapeHtml(row.received_at)}</td>
      <td>
        <details>
          <summary class="small">payload_json</summary>
          <pre class="small mb-0 mt-2 font-monospace">${escapeHtml(row.payload_json)}</pre>
        </details>
      </td>
    </tr>`).join('');

  return renderSectionShell(
    'Event Logs',
    'Latest event-bus messages persisted in as_event_logs.',
    `${renderFilterToolbar('/admin/event-logs', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>event_name</th><th>userid</th><th>username</th><th>received_at</th><th>payload_json</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderChangeLogsPage(result: AdminPageResult<AdminAchievementChangeLogRow>, state: PageState, options: AdminLayoutOptions): string {
  const rows = result.rows.map((row) => `
    <tr>
      <td>${row.id}</td>
      <td>${row.event_log_id}</td>
      <td>${row.achievement_id}</td>
      <td>${row.user_achievement_id}</td>
      <td class="font-monospace">${escapeHtml(row.event_name)}</td>
      <td class="font-monospace">${escapeHtml(row.userid)}</td>
      <td class="font-monospace">${escapeHtml(row.username ?? '')}</td>
      <td>${row.points_added}</td>
      <td>${row.progress_before}</td>
      <td>${row.progress_after}</td>
      <td>${row.achieved_before ? 'true' : 'false'}</td>
      <td>${row.achieved_after ? 'true' : 'false'}</td>
      <td>${escapeHtml(row.achieved_at ?? '')}</td>
      <td>${escapeHtml(row.created_at)}</td>
    </tr>`).join('');

  return renderSectionShell(
    'Change Logs',
    'Per-achievement progress changes persisted for each handled event.',
    `${renderFilterToolbar('/admin/change-logs', state, result.total)}
    <div class="table-wrapper">
      <table>
        <thead class="sticky-header"><tr><th>id</th><th>event_log_id</th><th>achievement_id</th><th>user_achievement_id</th><th>event_name</th><th>userid</th><th>username</th><th>points_added</th><th>progress_before</th><th>progress_after</th><th>achieved_before</th><th>achieved_after</th><th>achieved_at</th><th>created_at</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>`,
    options
  );
}

function renderNewAchievementPage(options: AdminLayoutOptions): string {
  return renderNewRecordPage(
    'New Achievement',
    'Create a new row in as_achievements.',
    '/admin/achievements',
    `
      <div class="col-12 col-md-6"><label class="form-label">code</label><input class="form-control form-control-sm font-monospace" name="code" required /></div>
      <div class="col-12 col-md-6"><label class="form-label">event_name</label><input class="form-control form-control-sm font-monospace" name="event_name" required /></div>
      <div class="col-12 col-md-4"><label class="form-label">icon_name</label><input class="form-control form-control-sm font-monospace" name="icon_name" /></div>
      <div class="col-6 col-md-4"><label class="form-label">points</label><input class="form-control form-control-sm font-monospace" name="points" type="number" value="1" required /></div>
      <div class="col-6 col-md-4"><label class="form-label">goal</label><input class="form-control form-control-sm font-monospace" name="goal" type="number" value="1" required /></div>
    `,
    '/admin/achievements/create',
    options
  );
}

function renderNewTranslationPage(options: AdminLayoutOptions): string {
  return renderNewRecordPage(
    'New Translation',
    'Create a new row in as_achievement_translations.',
    '/admin/translations',
    `
      <div class="col-12 col-md-3"><label class="form-label">achievement_id</label><input class="form-control form-control-sm font-monospace" name="achievement_id" type="number" required /></div>
      <div class="col-12 col-md-3"><label class="form-label">locale</label><input class="form-control form-control-sm font-monospace" name="locale" value="en" required /></div>
      <div class="col-12 col-md-6"><label class="form-label">title</label><input class="form-control form-control-sm font-monospace" name="title" /></div>
      <div class="col-12"><label class="form-label">description</label><input class="form-control form-control-sm font-monospace" name="description" /></div>
    `,
    '/admin/translations/create',
    options
  );
}

function renderNewEventListPage(options: AdminLayoutOptions): string {
  return renderNewRecordPage(
    'New Event List Row',
    'Create a new row in as_event_lists.',
    '/admin/event-lists',
    `
      <div class="col-12 col-md-8"><label class="form-label">event_name</label><input class="form-control form-control-sm font-monospace" name="event_name" required /></div>
      <div class="col-12 col-md-4"><label class="form-label">points</label><input class="form-control form-control-sm font-monospace" name="points" type="number" value="1" required /></div>
    `,
    '/admin/event-lists/create',
    options
  );
}

interface AdminRouterDependencies {
  authService: AdminAuthService;
  repository: AdminRepository;
  eventBus: EventBus;
  subscriberService: EventSubscriberService;
  logger: Logger;
  internalKey: string;
  achievementService: AchievementService;
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
      redirectWithNotice(res, '/admin/login', 'error', error instanceof Error ? error.message : 'Login failed.');
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

  router.get('/dashboard', async (req, res) => {
    try {
      const data = await deps.repository.getDashboardData();
      res.type('html').send(renderDashboardPage(pageOptions(req, res.locals.adminSession.email, 'dashboard'), data));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render achievement dashboard');
      redirectWithNotice(res, DEFAULT_ADMIN_PATH, 'error', error instanceof Error ? error.message : 'Failed to load dashboard.');
    }
  });

  router.get('/events', (req, res) => {
    void (async () => {
      try {
        const eventNames = await deps.repository.listAllEventNames();
        res.type('html').send(renderEventsPage(pageOptions(req, res.locals.adminSession.email, 'events'), eventNames));
      } catch (error) {
        deps.logger.error({ err: error }, 'failed to render manual event page');
        redirectWithNotice(res, '/admin/events', 'error', error instanceof Error ? error.message : 'Failed to load manual event page.');
      }
    })();
  });

  router.get('/api-docs', (req, res) => {
    res.type('html').send(renderSwaggerPage(pageOptions(req, res.locals.adminSession.email, 'api-docs')));
  });

  router.get('/api-docs/openapi.json', (_req, res) => {
    res.json(buildOpenApiDocument());
  });

  const apiDocsProxyRouter = express.Router();
  registerApiRoutes(apiDocsProxyRouter, deps.achievementService);
  router.use('/api-docs/proxy/api/v1', apiDocsProxyRouter);

  router.get('/achievements', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listAchievements(pageQuery(state));
      res.type('html').send(renderAchievementsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'achievements')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render achievements admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/achievements', state), 'error', error instanceof Error ? error.message : 'Failed to load achievements.');
    }
  });

  router.get('/achievements/new', (req, res) => {
    res.type('html').send(renderNewAchievementPage(pageOptions(req, res.locals.adminSession.email, 'achievements')));
  });

  router.get('/translations', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listTranslations(pageQuery(state));
      res.type('html').send(renderTranslationsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'translations')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render translations admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/translations', state), 'error', error instanceof Error ? error.message : 'Failed to load translations.');
    }
  });

  router.get('/translations/new', (req, res) => {
    res.type('html').send(renderNewTranslationPage(pageOptions(req, res.locals.adminSession.email, 'translations')));
  });

  router.get('/event-lists', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listEventLists(pageQuery(state));
      res.type('html').send(renderEventListsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'event-lists')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render event lists admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/event-lists', state), 'error', error instanceof Error ? error.message : 'Failed to load event lists.');
    }
  });

  router.get('/event-lists/new', (req, res) => {
    res.type('html').send(renderNewEventListPage(pageOptions(req, res.locals.adminSession.email, 'event-lists')));
  });

  router.get('/user-achievements', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listUserAchievements(pageQuery(state));
      res.type('html').send(renderUserAchievementsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'user-achievements')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render user achievements admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/user-achievements', state), 'error', error instanceof Error ? error.message : 'Failed to load user achievements.');
    }
  });

  router.get('/event-logs', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listEventLogs(pageQuery(state));
      res.type('html').send(renderEventLogsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'event-logs')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render event logs admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/event-logs', state), 'error', error instanceof Error ? error.message : 'Failed to load event logs.');
    }
  });

  router.get('/change-logs', async (req, res) => {
    const state = readPageState(req);
    try {
      const result = await deps.repository.listAchievementChangeLogs(pageQuery(state));
      res.type('html').send(renderChangeLogsPage(result, state, pageOptions(req, res.locals.adminSession.email, 'change-logs')));
    } catch (error) {
      deps.logger.error({ err: error }, 'failed to render change logs admin page');
      redirectWithNotice(res, buildSectionUrl('/admin/change-logs', state), 'error', error instanceof Error ? error.message : 'Failed to load change logs.');
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
      const eventNames = await deps.repository.listAllEventNames();
      const topic = readRequiredString(req.body, 'topic');
      const payloadText = readRequiredString(req.body, 'payload_json');
      const payload = normalizeManualEventPayload(topic, JSON.parse(payloadText));
      const userid = typeof payload.userid === 'string' && payload.userid.trim() !== '' ? payload.userid.trim() : null;
      const before = await captureEventTestState(deps.repository, userid);
      const ack = await deps.eventBus.publish(topic, payload);

      let after = before;
      const beforeEventLogCount = before.counts[0]?.count ?? 0;
      for (let attempt = 0; attempt < 10; attempt += 1) {
        await wait(200);
        after = await captureEventTestState(deps.repository, userid);
        if ((after.counts[0]?.count ?? 0) > beforeEventLogCount) {
          break;
        }
      }

      res.type('html').send(renderEventsPage(
        pageOptions(req, res.locals.adminSession.email, 'events'),
        eventNames,
        payloadText,
        {
          topic,
          ack,
          before,
          after,
        }
      ));
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
      redirectWithNotice(res, req.get('referer') || '/admin/achievements', 'notice', 'Achievement updated.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/achievements', 'error', error instanceof Error ? error.message : 'Failed to update achievement.');
    }
  });

  router.post('/achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteAchievement(Number(req.params.id));
      redirectWithNotice(res, req.get('referer') || '/admin/achievements', 'notice', 'Achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/achievements', 'error', error instanceof Error ? error.message : 'Failed to delete achievement.');
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
      redirectWithNotice(res, req.get('referer') || '/admin/translations', 'notice', 'Translation updated.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/translations', 'error', error instanceof Error ? error.message : 'Failed to update translation.');
    }
  });

  router.post('/translations/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteTranslation(Number(req.params.id));
      redirectWithNotice(res, req.get('referer') || '/admin/translations', 'notice', 'Translation deleted.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/translations', 'error', error instanceof Error ? error.message : 'Failed to delete translation.');
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
      redirectWithNotice(res, req.get('referer') || '/admin/event-lists', 'notice', 'Event list row updated and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/event-lists', 'error', error instanceof Error ? error.message : 'Failed to update event list row.');
    }
  });

  router.post('/event-lists/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteEventList(Number(req.params.id));
      await deps.subscriberService.refresh();
      redirectWithNotice(res, req.get('referer') || '/admin/event-lists', 'notice', 'Event list row deleted and subscriptions refreshed.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/event-lists', 'error', error instanceof Error ? error.message : 'Failed to delete event list row.');
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
      redirectWithNotice(res, req.get('referer') || '/admin/user-achievements', 'notice', 'User achievement updated.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/user-achievements', 'error', error instanceof Error ? error.message : 'Failed to update user achievement.');
    }
  });

  router.post('/user-achievements/:id/delete', async (req, res) => {
    try {
      await deps.repository.deleteUserAchievement(Number(req.params.id));
      redirectWithNotice(res, req.get('referer') || '/admin/user-achievements', 'notice', 'User achievement deleted.');
    } catch (error) {
      redirectWithNotice(res, req.get('referer') || '/admin/user-achievements', 'error', error instanceof Error ? error.message : 'Failed to delete user achievement.');
    }
  });

  return router;
}
