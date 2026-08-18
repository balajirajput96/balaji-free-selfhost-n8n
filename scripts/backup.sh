#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Missing .env."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source ./.env
set +a

STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p backup

docker compose exec -T postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" \
  | gzip > "backup/postgres-${STAMP}.sql.gz"
docker compose exec -T n8n n8n export:workflow --all --output=/tmp/workflows.json

docker compose cp n8n:/tmp/workflows.json "backup/workflows-${STAMP}.json"

echo "Backup created in $(pwd)/backup"
