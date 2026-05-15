#!/bin/bash

set -euo pipefail

load_dotenv_defaults() {
  if [ ! -f .env ]; then
    return
  fi

  while IFS= read -r line; do
    [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]] && continue
    local key="${line%%=*}"
    local value="${line#*=}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    [[ -z "${key}" || ! "${key}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && continue
    if [ -z "${!key+x}" ]; then
      export "${key}=${value}"
    fi
  done < .env
}

load_dotenv_defaults

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

require_command docker
require_command gcloud
require_env ACHIEVEMENT_INTERNAL_KEY
require_env DATABASE_PASSWORD
require_env EVENT_BUS_POSTGRES_URL

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
