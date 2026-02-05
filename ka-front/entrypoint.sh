#!/bin/sh
set -e

# Chemin du fichier généré par le build de Vite dans le container
CONFIG_FILE="/usr/share/nginx/html/config.js"

echo "🔧 Franz Ka Touch: Injecting variables into $CONFIG_FILE"

# Liste explicite des variables pour ne pas corrompre le reste du JS
VARS_TO_SUBST='$VITE_KEYCLOAK_URL $VITE_KEYCLOAK_REALM $VITE_KEYCLOAK_CLIENT_ID $VITE_API_URL'

# Substitution "In-place" sécurisée via un fichier temporaire
if [ -f "$CONFIG_FILE" ]; then
    envsubst "$VARS_TO_SUBST" < "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && \
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo "✅ Configuration successful."
else
    echo "⚠️ Warning: $CONFIG_FILE not found, skipping injection."
fi

# On passe la main au processus principal (Nginx)
# 'exec' permet à Nginx de recevoir les signaux d'arrêt (SIGTERM) proprement
exec nginx -g 'daemon off;'