import crypto from 'node:crypto';

export interface AdminSession {
  id: string;
  email: string;
  strapiToken: string;
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

    const session: AdminSession = {
      id: crypto.randomUUID(),
      email: readEmail(body, email),
      strapiToken: token,
    };
    this.sessions.set(session.id, session);
    return session;
  }
}
