#!/bin/bash
set -euo pipefail

echo "[start_app] Restarting bmi-backend service"
sudo systemctl restart bmi-backend

echo "[start_app] Validating and reloading nginx"
sudo nginx -t
sudo systemctl reload nginx
