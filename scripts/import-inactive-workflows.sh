#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Missing .env. Copy .env.example to .env and set strong secret values first."
  exit 1
fi

docker compose ps --status running --services | grep -qx n8n || {
  echo "n8n is not running. Start it first with: docker compose up -d"
  exit 1
}

# Imports only the normalized review copies. Each JSON has active=false.
docker compose exec -T n8n n8n import:workflow --separate --input=/workflows/inactive-import

echo "Imported inactive review drafts. Open n8n and connect credentials/test each workflow before any activation."
