#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/bmi-health-tracker-ec2-server"
echo "[before_install] Preparing $APP_DIR for deployment"

if [ ! -d "$APP_DIR/.git" ]; then
  echo "[before_install] $APP_DIR is not a git repo. It must be bootstrapped by user-data first." >&2
  exit 1
fi

if [ ! -f "$APP_DIR/backend/.env" ]; then
  echo "[before_install] Missing backend/.env — was this instance bootstrapped correctly?" >&2
  exit 1
fi

if systemctl is-active --quiet bmi-backend; then
  echo "[before_install] bmi-backend currently running (will be restarted after deploy)"
else
  echo "[before_install] bmi-backend not currently running"
fi
