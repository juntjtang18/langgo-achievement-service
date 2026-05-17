#!/bin/bash

set -euo pipefail

load_dotenv_defaults() {
  local env_file="$1"
  local key_regex="${2:-}"
  if [ ! -f "${env_file}" ]; then
    return
  fi

  while IFS= read -r line; do
    [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]] && continue
    local key="${line%%=*}"
    local value="${line#*=}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    [[ -z "${key}" || ! "${key}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && continue
    if [ -n "${key_regex}" ] && [[ ! "${key}" =~ ${key_regex} ]]; then
      continue
    fi
    if [ -z "${!key+x}" ]; then
      export "${key}=${value}"
    fi
  done < "${env_file}"
}

build_database_postgres_url() {
  node <<'NODE'
const encode = encodeURIComponent;
const user = encode(process.env.DATABASE_USERNAME || '');
const password = encode(process.env.DATABASE_PASSWORD || '');
const database = encode(process.env.DATABASE_NAME || '');
const port = encode(process.env.DATABASE_PORT || '5432');
const hostValue = process.env.DATABASE_HOST || '';
if (hostValue.startsWith('/')) {
  process.stdout.write(`postgresql://${user}:${password}@/${database}?host=${encode(hostValue)}&port=${port}`);
} else {
  process.stdout.write(`postgresql://${user}:${password}@${encode(hostValue)}:${port}/${database}`);
}
NODE
}

get_postgres_url_database_name() {
  node <<'NODE'
const connectionString = process.env.EVENT_BUS_POSTGRES_URL || '';
try {
  const url = new URL(connectionString);
  process.stdout.write(decodeURIComponent(url.pathname.replace(/^\/+/, '')));
} catch {
  const match = connectionString.match(/^postgres(?:ql)?:\/\/(?:[^/@]+@)?\/([^?]+)/);
  process.stdout.write(match && match[1] ? decodeURIComponent(match[1]) : '');
}
NODE
}

load_dotenv_defaults "../langgo_strapi4/.env" "^DATABASE_"
load_dotenv_defaults ".env"

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
DATABASE_NAME="${DATABASE_NAME:-langgo-en-dev2}"
DATABASE_USERNAME="${DATABASE_USERNAME:-strapi}"
DATABASE_SSL="${DATABASE_SSL:-false}"
EVENT_BUS_DRIVER="${EVENT_BUS_DRIVER:-postgres}"
EVENT_BUS_CHANNEL_PREFIX="${EVENT_BUS_CHANNEL_PREFIX:-event_bus}"

if [ "${DATABASE_NAME}" = "postgres" ] && [ "${ALLOW_POSTGRES_DATABASE:-false}" != "true" ]; then
  echo "Error: DATABASE_NAME=postgres is blocked. Use the same Strapi database as ../langgo_strapi4, or set ALLOW_POSTGRES_DATABASE=true intentionally."
  exit 1
fi

require_command docker
require_command gcloud
require_env ACHIEVEMENT_INTERNAL_KEY
require_env DATABASE_PASSWORD

if [ -z "${EVENT_BUS_POSTGRES_URL:-}" ]; then
  EVENT_BUS_POSTGRES_URL="$(build_database_postgres_url)"
fi

EVENT_BUS_DATABASE_NAME="$(get_postgres_url_database_name)"
if [ "${EVENT_BUS_DATABASE_NAME}" != "${DATABASE_NAME}" ]; then
  echo "Error: EVENT_BUS_POSTGRES_URL database '${EVENT_BUS_DATABASE_NAME}' must match DATABASE_NAME '${DATABASE_NAME}'."
  exit 1
fi

IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:${VERSION}"
REVISION_SUFFIX="v${VERSION//./-}"

echo "--- Deploying ${SERVICE_NAME} version ${VERSION} ---"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Image: ${IMAGE_NAME}"
echo "Event bus: driver=${EVENT_BUS_DRIVER}, channelPrefix=${EVENT_BUS_CHANNEL_PREFIX}, postgresUrlConfigured=yes"
echo "Database: host=${DATABASE_HOST}, database=${DATABASE_NAME}, schema=${ACHIEVEMENT_DB_SCHEMA}"

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
echo "--- Deployment of ${SERVICE_NAME} version ${VERSION} complete ---"
