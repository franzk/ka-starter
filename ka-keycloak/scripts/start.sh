#!/bin/bash
set -e

echo "=== Enter into Keycloak start.sh ==="

# Debugging: show environment variables
echo "KEYCLOAK_HOSTNAME=${KEYCLOAK_HOSTNAME}"

exec /opt/keycloak/bin/kc.sh start \
  --optimized \
  --import-realm \
  --http-enabled=true \
  --http-port=8080 \
  --proxy-headers=xforwarded \
  --hostname="${KEYCLOAK_HOSTNAME}" \
  --hostname-admin="${KEYCLOAK_HOSTNAME}"