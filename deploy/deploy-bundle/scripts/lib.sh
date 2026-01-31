#!/usr/bin/env bash
set -euo pipefail

#
# Determine which docker-compose files to use based on mode and deploy_mode
# Arguments:
#   mode: init|update
#   deploy_mode: ssh|registry
#
compose_files_for() {
  local mode="${1:?mode required}" # init|update
  local deploy_mode="${2:-ssh}"    # ssh|registry

  # Base compose file depends on deployment mode
  if [[ "$deploy_mode" == "registry" ]]; then
    echo "./docker-compose.registry.yml"
  else
    echo "./docker-compose.ssh.yml"
  fi

  if [[ -n "${PROXY_NETWORK_NAME:-}" ]]; then
    echo "./docker-compose.overlay-proxy.yml"
  fi

  if [[ "$mode" == "init" ]]; then
    echo "./docker-compose.overlay-init.yml"
  fi
}

#
# Assert that the proxy network exists if PROXY_NETWORK_NAME is set
#
assert_proxy_network_exists_if_needed() {
  if [[ -n "${PROXY_NETWORK_NAME:-}" ]]; then
    echo "🌐 Proxy mode enabled: PROXY_NETWORK_NAME=$PROXY_NETWORK_NAME"
    docker network inspect "$PROXY_NETWORK_NAME" >/dev/null 2>&1 || {
      echo "❌ Docker network '$PROXY_NETWORK_NAME' not found"
      exit 1
    }
  else
    echo "🌐 Proxy mode disabled (generic mode)"
  fi
}

#
# Run docker compose up with the given project name, deploy mode, and compose files
# Arguments:
#   project: Docker compose project name
#   deploy_mode: ssh|registry
docker_compose_up() {
  local project="${1:?project required}"
  local deploy_mode="${2:?deploy_mode required}"
  shift 2

  local -a args=(-p "$project")

  echo "🔧 Using deploy mode: $deploy_mode"

  assert_proxy_network_exists_if_needed

  for f in "$@"; do
    args+=(-f "$f")
  done

  echo "🚀 docker compose ${args[*]} pull"
  docker compose "${args[@]}" pull
  
  # Use --build for SSH mode, skip for registry mode
  if [[ "${deploy_mode:-ssh}" == "ssh" ]]; then
    echo "🚀 docker compose ${args[*]} up -d --build --force-recreate"
    docker compose "${args[@]}" up -d --build --force-recreate
  else
    echo "🚀 docker compose ${args[*]} up -d"
    docker compose "${args[@]}" up -d
  fi
  
  docker compose "${args[@]}" ps
}
