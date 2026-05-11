import type { Request, Response, Router } from 'express';
import express from 'express';
import type { Logger } from 'pino';
import type { EventBus } from '../types';
import {
  AdminRepository,
  type AdminAchievementRow,
  type AdminEventListRow,
  type AdminPageQuery,
  type AdminPageResult,
  type AdminTranslationRow,
  type AdminUserAchievementRow,
} from '../repositories/adminRepository';
import { AdminAuthService } from '../services/adminAuthService';
import { EventSubscriberService } from '../services/eventSubscriberService';

const SESSION_COOKIE = 'achievement_admin_session';
const DEFAULT_ADMIN_PATH = '/admin/events';
const DEFAULT_PAGE_SIZE = 20;

type AdminSection = 'events' | 'achievements' | 'translations' | 'event-lists' | 'user-achievements';

interface AdminLayoutOptions {
  notice?: string | null;
  error?: string | null;
  userEmail?: string | null;
  activeSection?: AdminSection;
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
  return `<a class="nav-link rounded px-3 py-2 ${activeSection === section ? 'active bg-primary text-white' : 'text-light'}" href="${href}" aria-current="${activeSection === section ? 'page' : 'false'}">${escapeHtml(label)}</a>`;
}

function iconButton(options: { label: string; icon: string; tone?: 'primary' | 'secondary' | 'danger'; formaction?: string; type?: 'submit' | 'button' }): string {
  const toneClass =
    options.tone === 'danger' ? 'btn-outline-danger' :
    options.tone === 'secondary' ? 'btn-outline-secondary' :
    'btn-primary';
  const formaction = options.formaction ? ` formaction="${escapeHtml(options.formaction)}"` : '';
  return `<button type="${options.type ?? 'submit'}" class="btn btn-sm ${toneClass}" title="${escapeHtml(options.label)}" aria-label="${escapeHtml(options.label)}"${formaction}><i class="bi bi-${escapeHtml(options.icon)}"></i></button>`;
}

function renderLayout(title: string, content: string, options: AdminLayoutOptions = {}): string {
  const notice = options.notice ? `<div class="alert alert-success" role="alert">${escapeHtml(options.notice)}</div>` : '';
  const error = options.error ? `<div class="alert alert-danger" role="alert">${escapeHtml(options.error)}</div>` : '';
  const userEmail = options.userEmail ? `<div class="text-secondary small mt-1">${escapeHtml(options.userEmail)}</div>` : '';
  const sidebar = options.activeSection ? `
    <aside class="position-fixed top-0 start-0 vh-100 text-bg-dark border-end" style="width: 248px;">
      <div class="p-3">
        <div class="fw-bold fs-5 text-white">Achievement Admin</div>
        <div class="text-secondary small mb-4">Standalone service control plane</div>
        <nav class="nav nav-pills flex-column gap-2">
          ${navLink('events', '/admin/events', 'Manual Event Emit', options.activeSection)}
          ${navLink('achievements', '/admin/achievements', 'Achievements', options.activeSection)}
          ${navLink('translations', '/admin/translations', 'Translations', options.activeSection)}
          ${navLink('event-lists', '/admin/event-lists', 'Event Lists', options.activeSection)}
          ${navLink('user-achievements', '/admin/user-achievements', 'User Achievements', options.activeSection)}
        </nav>
      </div>
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
      body { background: #f6f8fb; }
      .admin-main { margin-left: ${options.activeSection ? '248px' : '0'}; min-height: 100vh; }
      .table-responsive { overflow: auto; }
      th { white-space: nowrap; }
      .sticky-header th { position: sticky; top: 0; background: #fff; z-index: 1; }
      .where-help code { white-space: nowrap; }
      @media (max-width: 992px) {
        .admin-main { margin-left: 0; }
        aside.position-fixed { position: static !important; width: auto !important; height: auto !important; }
      }
    </style>
  </head>
  <body>
    ${sidebar}
    <main class="admin-main p-4">
      ${content.replace('<!--NOTICE-->', notice + error).replace('<!--USER-->', userEmail)}
    </main>
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
    `<div class="d-flex justify-content-between align-items-start gap-3 mb-4">
      <div>
        <h1 class="h3 mb-0">${escapeHtml(title)}</h1>
        <!--USER-->
      </div>
      <a class="btn btn-outline-secondary btn-sm" href="/admin/logout">Logout</a>
    </div>
    <!--NOTICE-->
    <div class="card shadow-sm border-0">
      <div class="card-body">
        <div class="mb-3">
          <h2 class="h5 mb-1">${escapeHtml(title)}</h2>
          <p class="text-secondary mb-0">${escapeHtml(description)}</p>
        </div>
        ${body}
      </div>
    </div>`,
    options
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
    <form method="get" action="${path}" class="row g-2 align-items-end mb-3">
      <div class="col-12 col-lg-7">
        <label class="form-label">where</label>
        <input class="form-control form-control-sm font-monospace" name="where" value="${escapeHtml(state.whereClause)}" placeholder="e.g. event_name = 'flashcard.create' AND points >= 1" />
        <div class="form-text where-help">Raw SQL sub-clause appended after <code>WHERE</code>. Column names must match DB fields exactly.</div>
      </div>
      <div class="col-6 col-lg-2">
        <label class="form-label">pageSize</label>
        <input class="form-control form-control-sm" name="pageSize" type="number" min="1" max="100" value="${state.pageSize}" />
      </div>
      <div class="col-6 col-lg-3">
        <input type="hidden" name="page" value="1" />
        <div class="d-flex gap-2">
          ${iconButton({ label: 'Apply filter', icon: 'search' })}
          <a class="btn btn-sm btn-outline-secondary" href="${path}"><i class="bi bi-arrow-clockwise"></i></a>
        </div>
      </div>
    </form>
    <div class="d-flex justify-content-between align-items-center mb-2">
      <div class="text-secondary small">total rows: ${total}</div>
      ${pagination(total, state, path)}
    </div>`;
}

function renderEventsPage(options: AdminLayoutOptions): string {
  return renderSectionShell(
    'Manual Event Emit',
    'Publish an event into the configured event bus to exercise the live achievement logic.',
    `<form method="post" action="/admin/events/emit" class="row g-3">
      <div class="col-12 col-lg-4">
        <label class="form-label">topic</label>
        <input class="form-control form-control-sm font-monospace" name="topic" placeholder="flashcard.review" required />
      </div>
      <div class="col-12 col-lg-8">
        <label class="form-label">payload_json</label>
        <textarea class="form-control form-control-sm font-monospace" name="payload_json" rows="6" placeholder='{"userid":"8","username":"vivian"}' required></textarea>
      </div>
      <div class="col-12 d-flex justify-content-end gap-2">
        ${iconButton({ label: 'Refresh subscriptions', icon: 'arrow-clockwise', tone: 'secondary', formaction: '/admin/subscriptions/refresh' })}
        ${iconButton({ label: 'Emit event', icon: 'send-fill' })}
      </div>
    </form>`,
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
    <div class="table-responsive">
      <table class="table table-sm align-middle">
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
    <div class="table-responsive">
      <table class="table table-sm align-middle">
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
    <div class="table-responsive">
      <table class="table table-sm align-middle">
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
    <div class="table-responsive">
      <table class="table table-sm align-middle">
        <thead class="sticky-header"><tr><th>id</th><th>userid</th><th>username</th><th>achievement_id</th><th>progress</th><th>achieved</th><th>achieved_at</th><th>actions</th></tr></thead>
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

  router.get('/events', (req, res) => {
    res.type('html').send(renderEventsPage(pageOptions(req, res.locals.adminSession.email, 'events')));
  });

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
      const payload = JSON.parse(readRequiredString(req.body, 'payload_json'));
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
