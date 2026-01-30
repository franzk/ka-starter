#!/usr/bin/env bash
set -euo pipefail

# Aller à la racine du projet (où se trouve ka-keycloak/)
cd "$(git rev-parse --show-toplevel)"

# --- preflight: perl ---
if ! command -v perl >/dev/null 2>&1; then
  echo "❌ perl is required but not installed."
  echo "👉 Please install perl (e.g. apt install perl / brew install perl)"
  exit 1
fi

SOURCE="ka-keycloak/realm-template.json"
TARGET="ka-keycloak/realm/realm-import.json"
PLACEHOLDER="https://app.change.me"

# APP_URL doit être passée via l'environnement (GitHub Actions) ou .env
: "${APP_URL:?APP_URL must be set in .env (e.g. https://app.franzka.net)}"

if [[ -z "$APP_URL" ]]; then
  echo "❌ APP_URL is empty. Please set it in .env (e.g. https://app.franzka.net)"
  exit 1
fi

if [[ ! -f "$SOURCE" ]]; then
  echo "❌ Realm export not found: $SOURCE"
  exit 1
fi

# Safety: ensure placeholder exists
if ! perl -0777 -ne 'exit(index($_, "https://app.change.me") >= 0 ? 0 : 1)' "$SOURCE"; then
  echo "❌ Placeholder '$PLACEHOLDER' not found in $SOURCE"
  exit 1
fi

# Generate realm-import.json
perl -pe "s|\Q$PLACEHOLDER\E|$APP_URL|g" "$SOURCE" > "$TARGET"

echo "✅ Realm import generated"
echo "   Source : $SOURCE"
echo "   Target : $TARGET"
echo "   Replace: $PLACEHOLDER → $APP_URL"
