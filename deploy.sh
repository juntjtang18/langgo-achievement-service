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

load_dotenv_defaults "../langgo_strapi4/.env" "^DATABASE_"
load_dotenv_defaults ".env"

sync_event_bus_client_dependency() {
  local repo_url="${EVENT_BUS_CLIENT_REPO_URL:-https://github.com/juntjtang18/event-bus-client.git}"
  local ref="${EVENT_BUS_CLIENT_REF:-main}"
  local cache_dir=".deploy-cache/event-bus-client"
  local commit_file=".deploy-cache/event-bus-client.commit"
  local vendor_dir="vendor"
  local tarball="${vendor_dir}/langgo-event-bus-client-0.1.0.tgz"
  local lock_needs_update="false"

  echo "Syncing event-bus-client dependency from ${repo_url} (${ref})..."

  mkdir -p ".deploy-cache" "${vendor_dir}"

  if [ ! -d "${cache_dir}/.git" ]; then
    rm -rf "${cache_dir}"
    git clone --depth 1 --branch "${ref}" "${repo_url}" "${cache_dir}"
  else
    git -C "${cache_dir}" fetch --depth 1 origin "${ref}"
    git -C "${cache_dir}" checkout --quiet FETCH_HEAD
  fi

  local commit
  commit="$(git -C "${cache_dir}" rev-parse HEAD)"

  if [ -f "${tarball}" ] && [ -f "${commit_file}" ] && [ "$(cat "${commit_file}")" = "${commit}" ]; then
    echo "event-bus-client already packed at ${commit}"
  else
    echo "Packing event-bus-client at ${commit}"
    npm --prefix "${cache_dir}" ci
    npm --prefix "${cache_dir}" run build
    rm -f "${vendor_dir}"/langgo-event-bus-client-*.tgz
    (cd "${cache_dir}" && npm pack --pack-destination "$(pwd)/../../${vendor_dir}" >/dev/null)
    echo "${commit}" > "${commit_file}"
    lock_needs_update="true"
  fi

  if [ ! -f "${tarball}" ]; then
    echo "Error: expected ${tarball} was not created."
    exit 1
  fi

  if ! grep -q '"event-bus-client": "file:vendor/langgo-event-bus-client-0.1.0.tgz"' package-lock.json 2>/dev/null; then
    lock_needs_update="true"
  fi

  if [ "${lock_needs_update}" = "true" ]; then
    npm install --package-lock-only --ignore-scripts
  fi
}

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

sync_event_bus_client_dependency

IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:${VERSION}"
REVISION_SUFFIX="v${VERSION//./-}-$(date -u +%Y%m%d%H%M%S)"

echo "--- Deploying ${SERVICE_NAME} version ${VERSION} ---"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Image: ${IMAGE_NAME}"
echo "Event bus: driver=${EVENT_BUS_DRIVER}, channelPrefix=${EVENT_BUS_CHANNEL_PREFIX}, postgresUrlSource=database-config"
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
  --set-env-vars "EVENT_BUS_CHANNEL_PREFIX=${EVENT_BUS_CHANNEL_PREFIX}" \
  --revision-suffix "${REVISION_SUFFIX}"

SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --format='value(status.url)')

echo "Service URL: ${SERVICE_URL}"
echo "--- Deployment of ${SERVICE_NAME} version ${VERSION} complete ---"
