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
- Internal API key auth via `x-internal-key`
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
- `ACHIEVEMENT_DB_SCHEMA=achievement_system`
- `DATABASE_PORT=5432`
- `DATABASE_SSL=false`
- `EVENT_BUS_DRIVER=postgres`
- `EVENT_BUS_CHANNEL_PREFIX=event_bus`

## Local Run

1. Install dependencies:

```bash
npm install
```

2. Set environment variables.

3. Start in watch mode:

```bash
npm run dev
```

4. Production build:

```bash
npm run build
npm run start
```

Example request:

```bash
curl \
  -H 'x-internal-key: replace-me' \
  -H 'x-user-id: 8' \
  -H 'x-username: vivian' \
  'http://localhost:8080/achievements-not-achieved?locale=en'
```

## Database Init

Startup sequence:

1. Connect to Postgres.
2. Create `ACHIEVEMENT_DB_SCHEMA` if missing.
3. Check for required tables.
4. If missing tables exist and `backup/*.sql` files are present, run those files.
5. Otherwise run `sql/init.sql`.
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

Build image:

```bash
docker build -t gcr.io/PROJECT_ID/langgo-achievement-server .
```

Deploy:

```bash
gcloud run deploy langgo-achievement-server \
  --image gcr.io/PROJECT_ID/langgo-achievement-server \
  --region us-west1 \
  --platform managed \
  --allow-unauthenticated=false \
  --set-env-vars PORT=8080
```

Add the remaining database, event bus, and internal key environment variables through `--set-env-vars`, Secret Manager, or your deployment config.

## Tests

```bash
npm test
```
