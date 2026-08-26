#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/bmi-health-tracker-ec2-server"
APP_PORT=$(grep -E '^PORT=' "$APP_DIR/backend/.env" | cut -d= -f2)

echo "[validate_service] Waiting for backend health on port $APP_PORT"
HEALTHY=0
for i in $(seq 1 20); do
  if curl -fsS "http://127.0.0.1:$APP_PORT/health" | grep -q '"status":"ok"'; then
    echo "[validate_service] Backend healthy"
    HEALTHY=1
    break
  fi
  echo "[validate_service] Waiting... ($i/20)"
  sleep 3
done

if [ "$HEALTHY" -ne 1 ]; then
  echo "[validate_service] Backend never became healthy" >&2
  sudo journalctl -u bmi-backend --no-pager -n 80 || true
  exit 1
fi

echo "[validate_service] Checking frontend via nginx"
if ! curl -fsS "http://127.0.0.1/" > /dev/null; then
  echo "[validate_service] Frontend not served by nginx" >&2
  exit 1
fi

echo "[validate_service] Deployment validated successfully"
