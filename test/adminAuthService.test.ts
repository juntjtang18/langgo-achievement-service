import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { AdminAuthService } from '../src/services/adminAuthService';

describe('AdminAuthService', () => {
  const originalFetch = global.fetch;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  afterEach(() => {
    global.fetch = originalFetch;
  });

  it('creates a session for a Strapi user with an admin role', async () => {
    global.fetch = vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify({
        data: {
          token: 'token-1',
          user: {
            email: 'admin@example.com',
          },
        },
      }), { status: 200, headers: { 'content-type': 'application/json' } }))
      .mockResolvedValueOnce(new Response(JSON.stringify({
        data: {
          email: 'admin@example.com',
          isActive: true,
          roles: [{ code: 'strapi-super-admin', name: 'Super Admin' }],
        },
      }), { status: 200, headers: { 'content-type': 'application/json' } })) as any;

    const service = new AdminAuthService('https://example.com/admin/auth/login');
    const session = await service.login('admin@example.com', 'secret');

    expect(session.email).toBe('admin@example.com');
    expect(session.strapiToken).toBe('token-1');
    expect(session.roles).toEqual(['strapi-super-admin']);
    expect(service.getSession(session.id)).toEqual(session);
  });

  it('rejects a Strapi user without an admin role and reports a clear hint', async () => {
    global.fetch = vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify({
        data: {
          token: 'token-2',
          user: {
            email: 'editor@example.com',
          },
        },
      }), { status: 200, headers: { 'content-type': 'application/json' } }))
      .mockResolvedValueOnce(new Response(JSON.stringify({
        data: {
          email: 'editor@example.com',
          isActive: true,
          roles: [{ code: 'editor', name: 'Editor' }],
        },
      }), { status: 200, headers: { 'content-type': 'application/json' } })) as any;

    const service = new AdminAuthService('https://example.com/admin/auth/login');

    await expect(service.login('editor@example.com', 'secret')).rejects.toThrow(
      'Only users with a Strapi admin role can sign in here.'
    );
  });
});
