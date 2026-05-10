#!/bin/bash

set -euo pipefail

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

require_env() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "Error: required environment variable ${name} is not set."
    exit 1
  fi
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Error: required command ${name} is not installed."
    exit 1
  fi
}

VERSION_FILE="VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0" > "$VERSION_FILE"
fi

VERSION=$(awk -F. -v OFS=. '{$NF++;print}' "$VERSION_FILE")
echo "$VERSION" > "$VERSION_FILE"

PROJECT_ID="${PROJECT_ID:-lucid-arch-451211-b0}"
SERVICE_NAME="${SERVICE_NAME:-achievement-service}"
REGION="${REGION:-us-west1}"
CLOUD_SQL_INSTANCE="${CLOUD_SQL_INSTANCE:-lucid-arch-451211-b0:us-west1:cloud-sql-server}"
VPC_CONNECTOR="${VPC_CONNECTOR:-langgo-vpc-connector}"
LOG_LEVEL="${LOG_LEVEL:-debug}"
ACHIEVEMENT_DB_SCHEMA="${ACHIEVEMENT_DB_SCHEMA:-achievement_system}"
DATABASE_CLIENT="${DATABASE_CLIENT:-postgres}"
DATABASE_HOST="${DATABASE_HOST:-/cloudsql/${CLOUD_SQL_INSTANCE}}"
DATABASE_PORT="${DATABASE_PORT:-5432}"
DATABASE_NAME="${DATABASE_NAME:-langgo-subsys-db1}"
DATABASE_USERNAME="${DATABASE_USERNAME:-strapi}"
DATABASE_SSL="${DATABASE_SSL:-false}"
EVENT_BUS_DRIVER="${EVENT_BUS_DRIVER:-postgres}"
EVENT_BUS_CHANNEL_PREFIX="${EVENT_BUS_CHANNEL_PREFIX:-event_bus}"
VERIFY_USER_ID="${VERIFY_USER_ID:-8}"
VERIFY_USERNAME="${VERIFY_USERNAME:-vivian}"
VERIFY_LOCALE="${VERIFY_LOCALE:-en}"

require_command docker
require_command gcloud
require_command node
require_command npm
require_env ACHIEVEMENT_INTERNAL_KEY
require_env DATABASE_PASSWORD
require_env EVENT_BUS_POSTGRES_URL

IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:${VERSION}"
REVISION_SUFFIX="v${VERSION//./-}"

echo "--- Deploying ${SERVICE_NAME} version ${VERSION} ---"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Image: ${IMAGE_NAME}"

echo "Generating restore SQL from ../langgo_strapi4 backup"
npm run generate:restore-sql

echo "Seeding achievement schema in Cloud SQL"
DATABASE_HOST="${DATABASE_HOST}" \
DATABASE_PORT="${DATABASE_PORT}" \
DATABASE_NAME="${DATABASE_NAME}" \
DATABASE_USERNAME="${DATABASE_USERNAME}" \
DATABASE_PASSWORD="${DATABASE_PASSWORD}" \
DATABASE_SSL="${DATABASE_SSL}" \
ACHIEVEMENT_DB_SCHEMA="${ACHIEVEMENT_DB_SCHEMA}" \
node <<'NODE'
const fs = require('node:fs/promises');
const path = require('node:path');
const { Client } = require('pg');

function quoteIdentifier(value) {
  return `"${value.replace(/"/g, '""')}"`;
}

function replaceSchema(sql, schema) {
  return sql.replaceAll('{{SCHEMA}}', quoteIdentifier(schema));
}

async function main() {
  const schema = process.env.ACHIEVEMENT_DB_SCHEMA || 'achievement_system';
  const client = new Client({
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT || '5432'),
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
  });

  await client.connect();
  try {
    await client.query(`CREATE SCHEMA IF NOT EXISTS ${quoteIdentifier(schema)}`);

    const files = [
      path.resolve(process.cwd(), 'sql/init.sql'),
      ...(
        await fs.readdir(path.resolve(process.cwd(), 'backup'))
      )
        .filter((file) => file.endsWith('.sql'))
        .sort()
        .map((file) => path.resolve(process.cwd(), 'backup', file)),
    ];

    for (const filePath of files) {
      const raw = await fs.readFile(filePath, 'utf8');
      const sql = replaceSchema(raw, schema);
      await client.query(sql);
      console.log(`Applied ${path.relative(process.cwd(), filePath)}`);
    }
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
NODE

echo "Building Docker image"
docker build -t "${IMAGE_NAME}" .

echo "Pushing Docker image"
docker push "${IMAGE_NAME}"

echo "Deploying to Cloud Run"
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE_NAME}" \
  --project "${PROJECT_ID}" \
  --platform managed \
  --region "${REGION}" \
  --memory 512Mi \
  --timeout 600 \
  --allow-unauthenticated \
  --add-cloudsql-instances "${CLOUD_SQL_INSTANCE}" \
  --vpc-connector "${VPC_CONNECTOR}" \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "LOG_LEVEL=${LOG_LEVEL}" \
  --set-env-vars "ACHIEVEMENT_INTERNAL_KEY=${ACHIEVEMENT_INTERNAL_KEY}" \
  --set-env-vars "ACHIEVEMENT_DB_SCHEMA=${ACHIEVEMENT_DB_SCHEMA}" \
  --set-env-vars "DATABASE_CLIENT=${DATABASE_CLIENT}" \
  --set-env-vars "DATABASE_HOST=${DATABASE_HOST}" \
  --set-env-vars "DATABASE_PORT=${DATABASE_PORT}" \
  --set-env-vars "DATABASE_NAME=${DATABASE_NAME}" \
  --set-env-vars "DATABASE_USERNAME=${DATABASE_USERNAME}" \
  --set-env-vars "DATABASE_PASSWORD=${DATABASE_PASSWORD}" \
  --set-env-vars "DATABASE_SSL=${DATABASE_SSL}" \
  --set-env-vars "EVENT_BUS_DRIVER=${EVENT_BUS_DRIVER}" \
  --set-env-vars "EVENT_BUS_POSTGRES_URL=${EVENT_BUS_POSTGRES_URL}" \
  --set-env-vars "EVENT_BUS_CHANNEL_PREFIX=${EVENT_BUS_CHANNEL_PREFIX}" \
  --revision-suffix "${REVISION_SUFFIX}"

SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --format='value(status.url)')

echo "Service URL: ${SERVICE_URL}"
echo "Verifying health endpoint"
HEALTH_RESPONSE=$(curl -fsS -H "x-internal-key: ${ACHIEVEMENT_INTERNAL_KEY}" "${SERVICE_URL}/healthz/")
echo "healthz response: ${HEALTH_RESPONSE}"
HEALTH_RESPONSE="${HEALTH_RESPONSE}" node <<'NODE'
const payload = JSON.parse(process.env.HEALTH_RESPONSE || '{}');
if (payload.ok !== true) {
  console.error('Health verification failed:', payload);
  process.exit(1);
}
console.log('Health verification passed.');
NODE

echo "Verifying achievement endpoint"
ACHIEVEMENT_RESPONSE=$(curl -fsS \
  -H "x-internal-key: ${ACHIEVEMENT_INTERNAL_KEY}" \
  -H "x-user-id: ${VERIFY_USER_ID}" \
  -H "x-username: ${VERIFY_USERNAME}" \
  "${SERVICE_URL}/achievements-not-achieved?locale=${VERIFY_LOCALE}")
echo "achievements-not-achieved response: ${ACHIEVEMENT_RESPONSE}"
ACHIEVEMENT_RESPONSE="${ACHIEVEMENT_RESPONSE}" node <<'NODE'
const payload = JSON.parse(process.env.ACHIEVEMENT_RESPONSE || '{}');
if (!Array.isArray(payload.data)) {
  console.error('Achievement verification failed: data is not an array', payload);
  process.exit(1);
}

const sample = payload.data[0];
if (sample) {
  const requiredKeys = [
    'id',
    'code',
    'event_name',
    'icon_name',
    'points',
    'goal',
    'progress',
    'achieved',
    'achieved_at',
    'title',
    'description',
  ];
  const missingKeys = requiredKeys.filter((key) => !(key in sample));
  if (missingKeys.length > 0) {
    console.error('Achievement verification failed: missing keys', missingKeys, sample);
    process.exit(1);
  }
}

console.log(`Achievement verification passed with ${payload.data.length} rows.`);
NODE

echo "--- Deployment of ${SERVICE_NAME} version ${VERSION} complete ---"
