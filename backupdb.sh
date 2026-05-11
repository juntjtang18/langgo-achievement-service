#!/bin/bash

set -euo pipefail

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
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

validate_schema() {
  local schema="$1"
  if [[ ! "$schema" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "Error: ACHIEVEMENT_DB_SCHEMA must be a simple SQL identifier. Got: $schema"
    exit 1
  fi
}

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${PROJECT_ROOT}/backup"
BACKUP_FILE="${BACKUP_DIR}/achievement-system-backup.sql"
TEMP_FILE="$(mktemp "${TMPDIR:-/tmp}/achievement-backup.XXXXXX.sql")"

cleanup() {
  rm -f "${TEMP_FILE}"
}

trap cleanup EXIT

require_command pg_dump
require_env DATABASE_HOST
require_env DATABASE_PORT
require_env DATABASE_NAME
require_env DATABASE_USERNAME
require_env DATABASE_PASSWORD

ACHIEVEMENT_DB_SCHEMA="${ACHIEVEMENT_DB_SCHEMA:-achievement_system}"
validate_schema "${ACHIEVEMENT_DB_SCHEMA}"

mkdir -p "${BACKUP_DIR}"

export PGPASSWORD="${DATABASE_PASSWORD}"

echo "Exporting schema ${ACHIEVEMENT_DB_SCHEMA} to ${BACKUP_FILE}"
pg_dump \
  --host="${DATABASE_HOST}" \
  --port="${DATABASE_PORT}" \
  --username="${DATABASE_USERNAME}" \
  --dbname="${DATABASE_NAME}" \
  --schema="${ACHIEVEMENT_DB_SCHEMA}" \
  --format=plain \
  --encoding=UTF8 \
  --verbose \
  --file="${TEMP_FILE}"

SCHEMA_PATTERN="${ACHIEVEMENT_DB_SCHEMA}"
perl \
  -pe "s/\\bSET search_path = ${SCHEMA_PATTERN}(,\\s*pg_catalog;)/SET search_path = {{SCHEMA}}\\1/g; s/\\bCREATE SCHEMA ${SCHEMA_PATTERN};/CREATE SCHEMA {{SCHEMA}};/g; s/\\bCREATE SCHEMA IF NOT EXISTS ${SCHEMA_PATTERN};/CREATE SCHEMA IF NOT EXISTS {{SCHEMA}};/g; s/\\bALTER SCHEMA ${SCHEMA_PATTERN}\\b/ALTER SCHEMA {{SCHEMA}}/g; s/\\bCOMMENT ON SCHEMA ${SCHEMA_PATTERN}\\b/COMMENT ON SCHEMA {{SCHEMA}}/g; s/\\bGRANT ([^\\n]+) ON SCHEMA ${SCHEMA_PATTERN}\\b/GRANT \\1 ON SCHEMA {{SCHEMA}}/g; s/\\bREVOKE ([^\\n]+) ON SCHEMA ${SCHEMA_PATTERN}\\b/REVOKE \\1 ON SCHEMA {{SCHEMA}}/g; s/\\b${SCHEMA_PATTERN}\\./{{SCHEMA}}./g;" \
  "${TEMP_FILE}" > "${BACKUP_FILE}"

echo "Backup complete: ${BACKUP_FILE}"
