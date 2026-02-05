#!/usr/bin/env bash

#
# Only for ssh deploy in init mode
# Render Keycloak realm-import.json from realm-template.json
# by replacing placeholders by APP_URL from .env
# Use it in init mode before deploying Keycloak
#

set -euo pipefail


# --- preflight: perl ---
if ! command -v perl >/dev/null 2>&1; then
  echo "❌ perl is required but not installed."
  echo "👉 Please install perl (e.g. apt install perl / brew install perl)"
  exit 1
fi

SOURCE="../../ka-keycloak/realm-template.json"
TARGET="../../ka-keycloak/realm/realm-import.json"
PLACEHOLDER="https://app.change.me"

# APP_URL must be passed via environment .env
: "${APP_URL:?APP_URL must be set in .env (e.g. https://app.franzka.net)}"

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
