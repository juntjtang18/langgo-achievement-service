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

validate_schema() {
  local schema="$1"
  if [[ ! "$schema" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "Error: ACHIEVEMENT_DB_SCHEMA must be a simple SQL identifier. Got: $schema"
    exit 1
  fi
}

confirm_fresh() {
  local schema="$1"
  if [ "${ASSUME_YES}" = "true" ]; then
    return
  fi

  echo "Fresh mode will DROP and recreate schema: ${schema}"
  printf "Type the schema name to continue: "
  read -r confirmation
  if [ "${confirmation}" != "${schema}" ]; then
    echo "Confirmation mismatch. Aborting."
    exit 1
  fi
}

psql_query() {
  local sql="$1"
  psql \
    --host="${DATABASE_HOST}" \
    --port="${DATABASE_PORT}" \
    --username="${DATABASE_USERNAME}" \
    --dbname="${DATABASE_NAME}" \
    --tuples-only \
    --no-align \
    --command="${sql}"
}

psql_exec_file() {
  local file="$1"
  psql \
    --host="${DATABASE_HOST}" \
    --port="${DATABASE_PORT}" \
    --username="${DATABASE_USERNAME}" \
    --dbname="${DATABASE_NAME}" \
    --set=ON_ERROR_STOP=1 \
    --file="${file}"
}

render_backup_sql() {
  local source_file="$1"
  local target_file="$2"
  perl -pe 's/\{\{SCHEMA\}\}/'"${ACHIEVEMENT_DB_SCHEMA}"'/g; s/^\s*CREATE SCHEMA\b.*$//g;' "${source_file}" > "${target_file}"
}

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUP_FILE="${PROJECT_ROOT}/backup/achievement-system-backup.sql"
RESTORE_FILE="$(mktemp "${TMPDIR:-/tmp}/achievement-restore.XXXXXX.sql")"
REQUIRED_TABLES=(
  "as_achievements"
  "as_achievement_translations"
  "as_event_lists"
  "as_user_achievements"
)

cleanup() {
  rm -f "${RESTORE_FILE}"
}

trap cleanup EXIT

FRESH_MODE="false"
ASSUME_YES="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --fresh)
      FRESH_MODE="true"
      ;;
    --yes)
      ASSUME_YES="true"
      ;;
    *)
      echo "Usage: ./setupdb.sh [--fresh] [--yes]"
      exit 1
      ;;
  esac
  shift
done

require_command psql
require_env DATABASE_HOST
require_env DATABASE_PORT
require_env DATABASE_NAME
require_env DATABASE_USERNAME
require_env DATABASE_PASSWORD

ACHIEVEMENT_DB_SCHEMA="${ACHIEVEMENT_DB_SCHEMA:-achievement_system}"
validate_schema "${ACHIEVEMENT_DB_SCHEMA}"

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Error: committed backup file not found: ${BACKUP_FILE}"
  exit 1
fi

export PGPASSWORD="${DATABASE_PASSWORD}"
render_backup_sql "${BACKUP_FILE}" "${RESTORE_FILE}"

if [ "${FRESH_MODE}" = "true" ]; then
  confirm_fresh "${ACHIEVEMENT_DB_SCHEMA}"
  echo "Dropping schema ${ACHIEVEMENT_DB_SCHEMA}"
  psql_query "DROP SCHEMA IF EXISTS \"${ACHIEVEMENT_DB_SCHEMA}\" CASCADE;" >/dev/null
  echo "Recreating schema ${ACHIEVEMENT_DB_SCHEMA}"
  psql_query "CREATE SCHEMA \"${ACHIEVEMENT_DB_SCHEMA}\";" >/dev/null
  echo "Applying committed backup SQL"
  psql_exec_file "${RESTORE_FILE}"
  echo "Fresh restore complete."
  exit 0
fi

echo "Ensuring schema ${ACHIEVEMENT_DB_SCHEMA} exists"
psql_query "CREATE SCHEMA IF NOT EXISTS \"${ACHIEVEMENT_DB_SCHEMA}\";" >/dev/null

missing_tables=()
for table_name in "${REQUIRED_TABLES[@]}"; do
  exists="$(psql_query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '${ACHIEVEMENT_DB_SCHEMA}' AND table_name = '${table_name}');" | tr -d '[:space:]')"
  if [ "${exists}" != "t" ]; then
    missing_tables+=("${table_name}")
  fi
done

if [ "${#missing_tables[@]}" -eq 0 ]; then
  echo "Required tables already exist in schema ${ACHIEVEMENT_DB_SCHEMA}. No changes made."
  exit 0
fi

echo "Missing required tables: ${missing_tables[*]}"
echo "Applying committed backup SQL without dropping existing schema."
psql_exec_file "${RESTORE_FILE}"
echo "Setup complete."
