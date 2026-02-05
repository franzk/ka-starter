#!/usr/bin/env bash

#
# Deploy script for Ka Starter project.
# usage :
# cd deploy/deploy-bundle/
# ./scripts/deploy.sh <ssh|registry> <init|update>
#

set -euo pipefail

DEPLOY_MODE="${1:-ssh}" # ssh|registry
MODE="${2:-update}" # init|update

case "$MODE" in
  init|update) ;;
  *)
    echo "Usage: ./deploy.sh <ssh|registry> <init|update>"
    exit 2
    ;;
esac

case "$DEPLOY_MODE" in
  ssh|registry) ;;
  *)
    echo "❌ Invalid DEPLOY_MODE: $DEPLOY_MODE (must be 'ssh' or 'registry')"
    echo "Usage: ./deploy.sh <ssh|registry> <init|update>"
    exit 2
    ;;
esac

# shellcheck disable=SC1091
source "./scripts/lib.sh"

# Load .env file (remove Windows CRLF line endings if present)
tr -d '\r' < .env > .env.tmp && mv .env.tmp .env
set -a; source .env; set +a

# Defaults AFTER loading .env
PROJECT="${PROJECT:-ka-starter}"

echo "🚀 Starting deployment with $DEPLOY_MODE mode, $MODE..."

# SSH deploy only (registry deploy does this in the pipeline)
# Init mode: generate realm-import.json from realm-template.json + APP_URL
if [[ "$DEPLOY_MODE" == "ssh" && "$MODE" == "init" ]]; then
  echo "🔧 Rendering Keycloak realm import..."
  chmod +x "./scripts/render-realm.sh"
  ./scripts/render-realm.sh
  inject_env_to_ka_front
fi

mapfile -t COMPOSE_FILES < <(compose_files_for "$MODE" "$DEPLOY_MODE")

echo "-> Deployment mode: $DEPLOY_MODE"
echo "-> Init/Update mode: $MODE"
echo "-> Project: $PROJECT"
echo "-> Compose files:"
printf "  - %s\n" "${COMPOSE_FILES[@]}"

docker_compose_up "$PROJECT" "$DEPLOY_MODE" "${COMPOSE_FILES[@]}"

echo "✅ Deployment complete."
