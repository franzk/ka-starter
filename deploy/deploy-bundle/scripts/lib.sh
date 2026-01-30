#!/usr/bin/env bash
set -euo pipefail

load_env() {
  local env_file="${1:?env_file required}"

  if [[ ! -f "$env_file" ]]; then
    echo "❌ $env_file not found."
    exit 0
  fi

  # Portable .env loader.
  # Supports simple KEY=VALUE lines and ignores comments/blank lines.
  # Does not try to interpret quotes/escapes; keep .env simple.
  while IFS= read -r line || [[ -n "$line" ]]; do
    # remove CR if present (Windows line endings)
    line="${line%$'\r'}"

    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue
    [[ "$line" != *"="* ]] && continue

    local key="${line%%=*}"
    local val="${line#*=}"

    # trim spaces around key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    # remove trailing CR/LF from value
    val="${val%$'\r'}"
    val="${val%$'\n'}"

    [[ -n "$key" && -z "${!key:-}" ]] && export "$key=$val"
  done < "$env_file"

  echo "✅ Loaded environment variables from $env_file"
}

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
