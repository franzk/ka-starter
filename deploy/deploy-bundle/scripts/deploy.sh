#!/usr/bin/env bash
set -euo pipefail

DEPLOY_MODE="${1:-ssh}" # ssh|registry
MODE="${2:-update}" # init|update

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

# Load .env file
set -a; source .env; set +a

# Defaults AFTER load_env
PROJECT="${PROJECT:-ka-starter}"

#  peut etre pour ssh
# Only for init: generate realm-import.json from realm-template.json + APP_URL
# if [[ "$MODE" == "init" ]]; then
#   chmod +x "./scripts/render-realm.sh"
#   ./scripts/render-realm.sh
# fi

mapfile -t COMPOSE_FILES < <(compose_files_for "$MODE" "$DEPLOY_MODE")

echo "-> Deployment mode: $DEPLOY_MODE"
echo "-> Init/Update mode: $MODE"
echo "-> Project: $PROJECT"
echo "-> Compose files:"
printf "  - %s\n" "${COMPOSE_FILES[@]}"

docker_compose_up "$PROJECT" "$DEPLOY_MODE" "${COMPOSE_FILES[@]}"

echo "✅ Deployment complete."
