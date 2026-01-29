#!/usr/bin/env bash
set -euo pipefail

# Go to repo root (deploy/scripts -> repo root)
cd "$(dirname "$0")/../.."

MODE="${1:-update}" # init|update
DEPLOY_MODE="${DEPLOY_MODE:-ssh}" # ssh|registry TODO : make this a param?

case "$MODE" in
  init|update) ;;
  *)
    echo "Usage: deploy/scripts/deploy.sh <init|update>"
    exit 2
    ;;
esac

case "$DEPLOY_MODE" in
  ssh|registry) ;;
  *)
    echo "❌ Invalid DEPLOY_MODE: $DEPLOY_MODE (must be 'ssh' or 'registry')"
    exit 2
    ;;
esac

# shellcheck disable=SC1091
source "./scripts/lib.sh"

# Always load .env
load_env ".env"

# Defaults AFTER load_env
PROJECT="${PROJECT:-ka-starter}"

# Only for init: generate realm-import.json from realm-template.json + APP_URL
if [[ "$MODE" == "init" ]]; then
  ./scripts/render-realm.sh
fi

mapfile -t COMPOSE_FILES < <(compose_files_for "$MODE" "$DEPLOY_MODE")

echo "-> Deployment mode: $DEPLOY_MODE"
echo "-> Init/Update mode: $MODE"
echo "-> Project: $PROJECT"
echo "-> Compose files:"
printf "  - %s\n" "${COMPOSE_FILES[@]}"

docker_compose_up "$PROJECT" ".env" "${COMPOSE_FILES[@]}"

echo "✅ Deployment complete."
