#!/usr/bin/env bash
set -euo pipefail

# Go to repo root (deploy/scripts -> repo root)
cd "$(dirname "$0")/../.."

MODE="${1:-update}" # init|update

case "$MODE" in
  init|update) ;;
  *)
    echo "Usage: deploy/scripts/deploy.sh <init|update>"
    exit 2
    ;;
esac

# shellcheck disable=SC1091
source "./deploy/scripts/lib.sh"

# Always load .env
load_env ".env"

# Defaults AFTER load_env
PROJECT="${PROJECT:-ka-starter}"

# Only for init: generate realm-import.json from realm-template.json + APP_URL
if [[ "$MODE" == "init" ]]; then
  ./deploy/scripts/render-realm.sh
fi

mapfile -t COMPOSE_FILES < <(compose_files_for "$MODE")

echo "-> Mode: $MODE"
echo "-> Project: $PROJECT"
echo "-> Compose files:"
printf "  - %s\n" "${COMPOSE_FILES[@]}"

docker_compose_up "$PROJECT" ".env" "${COMPOSE_FILES[@]}"

echo "✅ Deployment complete."
