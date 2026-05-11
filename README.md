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
- Postgres schema bootstrap support plus explicit DB backup/setup scripts
- Event-bus subscription using the Postgres event bus client
- Audit persistence for received events and per-achievement point changes
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
./setupdb.sh
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
- `as_event_logs`
- `as_achievement_change_logs`

The admin page also includes a manual event publisher that sends JSON payloads through the configured event bus so you can test the live achievement logic.
Manual emit now normalizes legacy payloads like `{"userid":"8","username":"vivian"}` into the shared event-bus shape by filling top-level `eventId`, `event_name`, and `userId`. It also includes `eventName` as a compatibility alias for older subscribers.

Admin table pages use Bootstrap styling and are route-based:

- `/admin/events`
- `/admin/achievements`
- `/admin/translations`
- `/admin/event-lists`
- `/admin/user-achievements`
- `/admin/event-logs`
- `/admin/change-logs`

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

## Database Workflow

Use the committed plain SQL backup in [backup/achievement-system-backup.sql](/Users/James/develop/langgo/langgo-achievement-server/backup/achievement-system-backup.sql) as the restore source of truth.

Initialize the DB safely:

```bash
./setupdb.sh
```

Destructive reset:

```bash
./setupdb.sh --fresh
./setupdb.sh --fresh --yes
```

Export the current schema and data back into the committed backup file:

```bash
./backupdb.sh
```

`backupdb.sh`:

- loads `.env`
- exports only `ACHIEVEMENT_DB_SCHEMA`
- writes plain SQL to `backup/achievement-system-backup.sql`
- includes schema objects, indexes, constraints, defaults, sequences, and data
- intentionally omits DB users, roles, ownership, and privileges because they are not required for this service restore

`setupdb.sh`:

- loads `.env`
- validates `ACHIEVEMENT_DB_SCHEMA`
- creates the schema if missing
- does nothing if required tables already exist
- restores only from the committed backup SQL if required tables are missing
- drops only `ACHIEVEMENT_DB_SCHEMA` in `--fresh` mode

The committed backup SQL uses a `{{SCHEMA}}` placeholder so the same backup can be restored into any valid `ACHIEVEMENT_DB_SCHEMA`.

To regenerate the Strapi-derived seed file from `../langgo_strapi4/database/backup/langgo_full.sql`:

```bash
npm run generate:restore-sql
```

This writes [backup/strapi4-achievement-data.restore.sql](/Users/James/develop/langgo/langgo-achievement-server/backup/strapi4-achievement-data.restore.sql), flattening Strapi relation-link tables into this service's direct `achievement_id` model.

## Event Handling

Subscribed event names come from `as_event_lists.event_name`.

Incoming events map to the old Strapi behavior:

- canonical event-bus payload aligned with the Swift client field naming:
  `topic = event name`, payload uses top-level `eventId`, `event_name`, `userId`, and `username`
- compatibility aliases still accepted: `eventName`, `user_id`, `userid`, `userName`, and nested `review` / `flashcard` / `article` user fields
- user id from top-level `payload.user_id`, `payload.userid`, `payload.userId`, then nested `review`, `flashcard`, or `article`
- username from `payload.username`, `payload.userName`, nested `review`, `flashcard`, or `article`
- progress increment uses `as_achievements.points`
- achievement completes when `progress >= goal`

Every received event is persisted to `as_event_logs` first. Any resulting progress mutations are persisted to `as_achievement_change_logs` in the same DB transaction.

## Cloud Run

Use the provided deploy script:

```bash
./deploy.sh
```

`deploy.sh` does the following:

- builds and pushes the Docker image
- deploys the Cloud Run service

It does not create, reset, seed, or restore the database. Run `./setupdb.sh` separately if the target DB schema needs to be installed first.

The script relies on the GitHub `event-bus-client` dependency through the Docker build. The build stage installs `git`, so GitHub-based npm dependencies resolve correctly in Cloud Run image builds.

## Tests

```bash
npm test
```
