# LangGo Achievement Server

Standalone Node.js achievement service extracted from the Strapi achievement plugin in `../langgo_strapi4`, with compatible fetch endpoints and Postgres-backed event-bus subscriptions for Cloud Run.

## Dependency Note

This service consumes `event-bus-client` directly from GitHub:

```json
"event-bus-client": "github:juntjtang18/event-bus-client#main"
```

For development, `#main` is acceptable. For production deployments, pin this dependency to a tag or commit SHA instead of a floating branch reference, for example:

```json
"event-bus-client": "github:juntjtang18/event-bus-client#<tag-or-commit>"
```

The upstream package includes a `prepare` script, so installing from GitHub builds the package during `npm install`. The Docker build stage installs `git` to support GitHub-based package installation.

## Features

- `GET /achievements-achieved`
- `GET /achievements-not-achieved`
- `GET /healthz`
- `GET /admin/login` and `GET /admin`
- Internal API key auth via `x-internal-key`
- Strapi-admin-backed authentication for the built-in admin UI
- Postgres schema bootstrap and optional `backup/*.sql` restore
- Event-bus subscription using the Postgres event bus client
- Graceful shutdown and structured logs

## Environment

Use `.env.example` as the baseline. Required variables:

- `ACHIEVEMENT_INTERNAL_KEY`
- `DATABASE_HOST`
- `DATABASE_NAME`
- `DATABASE_USERNAME`
- `DATABASE_PASSWORD`
- `EVENT_BUS_POSTGRES_URL`

Defaults:

- `PORT=8080`
- `STRAPI_ADMIN_URL=https://langgo-en-strapi.geniusparentingai.ca/admin/auth/login`
- `ACHIEVEMENT_DB_SCHEMA=achievement_system`
- `DATABASE_PORT=5432`
- `DATABASE_SSL=false`
- `EVENT_BUS_DRIVER=postgres`
- `EVENT_BUS_CHANNEL_PREFIX=event_bus`

The server now auto-loads a local `.env` file if one exists in the project root. If `.env` is absent, it falls back to the existing shell environment and the built-in defaults above.

## Local Run

1. Install dependencies:

```bash
npm install
```

2. Create `.env` from the example and fill in the real values:

```bash
cp .env.example .env
```

3. Start in watch mode:

```bash
npm run dev
```

4. Production build:

```bash
npm run build
npm run start
```

5. Open the admin UI:

```text
http://localhost:8080/admin/login
```

The admin login form authenticates against `STRAPI_ADMIN_URL`, verifies the Strapi user is active and has an admin role, then gives access to CRUD screens for:

- `as_achievements`
- `as_achievement_translations`
- `as_event_lists`
- `as_user_achievements`

The admin page also includes a manual event publisher that sends JSON payloads through the configured event bus so you can test the live achievement logic.

Admin table pages use Bootstrap styling and are route-based:

- `/admin/events`
- `/admin/achievements`
- `/admin/translations`
- `/admin/event-lists`
- `/admin/user-achievements`

Each CRUD table page supports:

- pagination with `page` and `pageSize`
- a raw `where` filter input appended after `WHERE (...)`
- DB-field-exact column names so they can be referenced directly in the `where` clause

Example request:

```bash
curl \
  -H 'x-internal-key: replace-me' \
  -H 'x-user-id: 8' \
  'http://localhost:8080/achievements-not-achieved?locale=en'
```

## Database Init

Startup sequence:

1. Connect to Postgres.
2. Create `ACHIEVEMENT_DB_SCHEMA` if missing.
3. Check for required tables.
4. If required tables are missing, restore from `backup/*.sql` when present or create tables from `sql/init.sql`.
5. If tables already exist but `as_achievements` is empty, retry restore from `backup/*.sql`.
6. Start HTTP and event subscriptions only after initialization succeeds.

The SQL files use a `{{SCHEMA}}` placeholder so the same scripts can initialize any configured schema.

To regenerate the Strapi data restore file from `../langgo_strapi4/database/backup/langgo_full.sql`:

```bash
npm run generate:restore-sql
```

This writes [backup/strapi4-achievement-data.restore.sql](/Users/James/develop/langgo/langgo-achievement-server/backup/strapi4-achievement-data.restore.sql), flattening Strapi relation-link tables into this service's direct `achievement_id` model.

## Event Handling

Subscribed event names come from `as_event_lists.event_name`.

Incoming events map to the old Strapi behavior:

- user id from `payload.userid`, `payload.userId`, nested `review`, `flashcard`, or `article`
- username from `payload.username`, `payload.userName`, nested `review`, `flashcard`, or `article`
- progress increment uses `as_achievements.points`
- achievement completes when `progress >= goal`

## Cloud Run

Use the provided deploy script:

```bash
./deploy.sh
```

`deploy.sh` does the following:

- regenerates `backup/strapi4-achievement-data.restore.sql`
- applies `sql/init.sql` and `backup/*.sql` to the configured Cloud SQL schema
- builds and pushes the Docker image
- deploys the Cloud Run service
- verifies `/healthz`
- verifies `/achievements-not-achieved` returns `{ "data": [...] }` with the expected achievement fields

The script relies on the GitHub `event-bus-client` dependency through the Docker build. The build stage installs `git`, so GitHub-based npm dependencies resolve correctly in Cloud Run image builds.

## Tests

```bash
npm test
```
