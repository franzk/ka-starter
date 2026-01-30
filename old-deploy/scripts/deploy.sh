#!/usr/bin/env bash
set -euo pipefail

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Aller à la racine du déploiement (parent du dossier scripts)
cd "$SCRIPT_DIR/.."

MODE="${1:-update}" # init|update
DEPLOY_MODE="${DEPLOY_MODE:-ssh}" # ssh|registry

case "$MODE" in
  init|update) ;;
  *)
    echo "Usage: deploy.sh <init|update>"
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

# Charger les fonctions helper
source "$SCRIPT_DIR/lib.sh"

# Charger .env
load_env ".env"

# Defaults AFTER load_env
PROJECT="${PROJECT:-ka-starter}"

# Only for init: generate realm-import.json from realm-template.json + APP_URL
if [[ "$MODE" == "init" ]]; then
  if [[ -f "$SCRIPT_DIR/render-realm.sh" ]]; then
    "$SCRIPT_DIR/render-realm.sh"
  else
    echo "⚠️  render-realm.sh not found, skipping realm generation"
  fi
fi

mapfile -t COMPOSE_FILES < <(compose_files_for "$MODE" "$DEPLOY_MODE")

echo "-> Deployment mode: $DEPLOY_MODE"
echo "-> Init/Update mode: $MODE"
echo "-> Project: $PROJECT"
echo "-> Compose files:"
printf "  - %s\n" "${COMPOSE_FILES[@]}"

docker_compose_up "$PROJECT" ".env" "${COMPOSE_FILES[@]}"

echo "✅ Deployment complete."