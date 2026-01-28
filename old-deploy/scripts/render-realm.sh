#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

# --- preflight: perl ---
if ! command -v perl >/dev/null 2>&1; then
  echo "❌ perl is required but not installed."
  echo "👉 Please install perl (e.g. apt install perl / brew install perl)"
  exit 1
fi

ENV_FILE="${ENV_FILE:-.env}"
SOURCE="ka-keycloak/realm-template.json"
TARGET="ka-keycloak/realm/realm-import.json"
PLACEHOLDER="https://app.change.me"

# --- minimal .env loader (portable, no sed) ---
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ $ENV_FILE not found."
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue
  [[ "$line" != *"="* ]] && continue

  key="${line%%=*}"
  val="${line#*=}"

  # trim spaces
  key="${key#"${key%%[![:space:]]*}"}"
  key="${key%"${key##*[![:space:]]}"}"

  [[ -n "$key" && -z "${!key:-}" ]] && export "$key=$val"
done < "$ENV_FILE"

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
