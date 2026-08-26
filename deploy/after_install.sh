#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/bmi-health-tracker-ec2-server"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"

echo "[after_install] Installing backend dependencies"
cd "$BACKEND_DIR"
npm install --no-audit --no-fund --omit=dev

echo "[after_install] Installing frontend dependencies and building"
cd "$FRONTEND_DIR"
npm install --no-audit --no-fund
npm run build

echo "[after_install] Checking for pending DB migrations"
MIGRATION_FILE="$APP_DIR/database/migrations/001_create_measurements.sql"
if [ -f "$MIGRATION_FILE" ]; then
  set -a
  source "$BACKEND_DIR/.env"
  set +a
  # DATABASE_URL looks like postgresql://user:pass@host:5432/dbname
  DB_USER=$(echo "$DATABASE_URL" | sed -E 's#postgresql://([^:]+):.*#\1#')
  DB_PASS=$(echo "$DATABASE_URL" | sed -E 's#postgresql://[^:]+:([^@]+)@.*#\1#')
  DB_NAME=$(echo "$DATABASE_URL" | sed -E 's#.*/([^/?]+)(\?.*)?$#\1#')
  PGPASSWORD="$DB_PASS" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -f "$MIGRATION_FILE" || \
    echo "[after_install] Migration already applied or failed non-fatally"
fi
