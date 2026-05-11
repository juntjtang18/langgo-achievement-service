import crypto from 'node:crypto';

export interface AdminSession {
  id: string;
  email: string;
  strapiToken: string;
  roles: string[];
}

function normalizeStrapiAdminOrigin(value: string): string {
  const url = new URL(value);
  return `${url.protocol}//${url.host}`;
}

function readToken(body: any): string | null {
  return body?.data?.token ?? body?.token ?? null;
}

function readEmail(body: any, fallbackEmail: string): string {
  return body?.data?.user?.email ?? body?.user?.email ?? fallbackEmail;
}

function normalizeRoleName(role: unknown): string | null {
  if (typeof role === 'string') {
    const normalized = role.trim();
    return normalized === '' ? null : normalized;
  }

  if (!role || typeof role !== 'object') {
    return null;
  }

  const candidate = (role as Record<string, unknown>).code
    ?? (role as Record<string, unknown>).name
    ?? (role as Record<string, unknown>).type;

  return typeof candidate === 'string' && candidate.trim() !== '' ? candidate.trim() : null;
}

function extractRoles(body: any): string[] {
  const candidates = [
    body?.data?.roles,
    body?.data?.user?.roles,
    body?.roles,
    body?.user?.roles,
  ];

  const singular = [
    body?.data?.role,
    body?.data?.user?.role,
    body?.role,
    body?.user?.role,
  ];

  const values = candidates.flatMap((value) => Array.isArray(value) ? value : [])
    .concat(singular.filter((value) => value != null));

  return Array.from(new Set(values.map(normalizeRoleName).filter((value): value is string => value !== null)));
}

function isActiveUser(body: any): boolean {
  const value = body?.data?.isActive
    ?? body?.data?.user?.isActive
    ?? body?.isActive
    ?? body?.user?.isActive;

  return value !== false;
}

function hasAdminRole(roles: string[]): boolean {
  return roles.some((role) => role.toLowerCase().includes('admin'));
}

async function parseJson(response: Response): Promise<any> {
  return response.json().catch(() => ({}));
}

export class AdminAuthService {
  private readonly sessions = new Map<string, AdminSession>();
  private readonly adminOrigin: string;

  constructor(strapiAdminUrl: string) {
    this.adminOrigin = normalizeStrapiAdminOrigin(strapiAdminUrl);
  }

  getLoginUrl(): string {
    return `${this.adminOrigin}/admin/auth/login`;
  }

  getSession(sessionId: string | null | undefined): AdminSession | null {
    if (!sessionId) {
      return null;
    }
    return this.sessions.get(sessionId) ?? null;
  }

  deleteSession(sessionId: string | null | undefined): void {
    if (!sessionId) {
      return;
    }
    this.sessions.delete(sessionId);
  }

  private async fetchProfile(token: string): Promise<any | null> {
    for (const path of ['/admin/users/me', '/admin/me']) {
      const response = await fetch(`${this.adminOrigin}${path}`, {
        headers: {
          authorization: `Bearer ${token}`,
          accept: 'application/json',
        },
      });

      if (response.ok) {
        return parseJson(response);
      }

      if (response.status !== 404) {
        const body = await parseJson(response);
        const message = body?.error?.message ?? body?.message ?? `Failed to load Strapi admin profile from ${path}.`;
        throw new Error(message);
      }
    }

    return null;
  }

  async login(email: string, password: string): Promise<AdminSession> {
    const response = await fetch(`${this.adminOrigin}/admin/login`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    });

    const body = await response.json().catch(() => ({}));
    if (!response.ok) {
      const message = body?.error?.message ?? body?.message ?? 'Strapi admin login failed.';
      throw new Error(message);
    }

    const token = readToken(body);
    if (!token) {
      throw new Error('Strapi admin login did not return a token.');
    }

    const profile = await this.fetchProfile(token);
    const roles = Array.from(new Set([
      ...extractRoles(body),
      ...extractRoles(profile),
    ]));

    if (!isActiveUser(body) || (profile && !isActiveUser(profile))) {
      throw new Error('Your Strapi admin account is inactive. Contact an administrator.');
    }

    if (!hasAdminRole(roles)) {
      throw new Error('Only users with a Strapi admin role can sign in here.');
    }

    const session: AdminSession = {
      id: crypto.randomUUID(),
      email: readEmail(body, email),
      strapiToken: token,
      roles,
    };
    this.sessions.set(session.id, session);
    return session;
  }
}
