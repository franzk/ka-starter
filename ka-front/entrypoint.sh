#!/bin/sh
set -e

# replace placeholders in config.js with actual environment variables
export KEYCLOAK_URL="${VITE_KEYCLOAK_URL}"
export KEYCLOAK_REALM="${VITE_KEYCLOAK_REALM}"
export KEYCLOAK_CLIENT_ID="${VITE_KEYCLOAK_CLIENT_ID}"
export API_URL="${VITE_API_URL}"

envsubst "${KEYCLOAK_URL} ${KEYCLOAK_REALM} ${KEYCLOAK_CLIENT_ID} ${API_URL}" \
  < /usr/share/nginx/html/config.js \
  > /usr/share/nginx/html/config.js.tmp

mv /usr/share/nginx/html/config.js.tmp /usr/share/nginx/html/config.js

echo "✅ Config updated with runtime environment variables"

# Démarrer Nginx
exec nginx -g 'daemon off;'