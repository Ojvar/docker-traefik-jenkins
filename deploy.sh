#!/usr/bin/env bash
set -euo pipefail

STACK_PREFIX="ojvar"
TRAEFIK_STACK="${STACK_PREFIX}-traefik-stack"
JENKINS_STACK="${STACK_PREFIX}-jenkins-stack"
POSTGRES_STACK="${STACK_PREFIX}-postgres-stack"
NETWORK="public-net"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAEFIK_DIR="${ROOT_DIR}/traefik"
JENKINS_DIR="${ROOT_DIR}/jenkins"
POSTGRES_DIR="${ROOT_DIR}/postgres"

usage() {
  echo "Usage: $0 {start|stop|restart|status}"
  exit 1
}

ensure_network() {
  if docker network inspect "${NETWORK}" >/dev/null 2>&1; then
    echo "✔ Network '${NETWORK}' already exists. Skipping creation."
  else
    echo "🧱 Creating overlay network '${NETWORK}'..."
    docker network create --driver overlay "${NETWORK}"
    echo "✅ Network '${NETWORK}' created."
  fi
}

ensure_dirs() {
  mkdir -p "${TRAEFIK_DIR}/data"
  mkdir -p "${JENKINS_DIR}/jenkins_home"
  mkdir -p "${POSTGRES_DIR}/postgres_data"
  mkdir -p "${POSTGRES_DIR}/pgadmin_data"

  local ACME_FILE="${TRAEFIK_DIR}/data/acme.json"
  if [ ! -f "${ACME_FILE}" ]; then
    echo "{}" > "${ACME_FILE}"
    chmod 600 "${ACME_FILE}"
  fi
}

deploy_stacks() {
  echo "🚀 Deploying Traefik stack (${TRAEFIK_STACK})..."
  docker stack deploy -c "${TRAEFIK_DIR}/docker-compose.yml" "${TRAEFIK_STACK}"

  echo "🚀 Deploying Jenkins stack (${JENKINS_STACK})..."
  docker stack deploy -c "${JENKINS_DIR}/docker-compose.yml" "${JENKINS_STACK}"

  echo "🚀 Deploying PostgreSQL stack (${POSTGRES_STACK})..."
  docker stack deploy -c "${POSTGRES_DIR}/docker-compose.yml" "${POSTGRES_STACK}"
}

remove_stacks() {
  echo "🧹 Removing PostgreSQL stack (${POSTGRES_STACK})..."
  docker stack rm "${POSTGRES_STACK}" || true
  echo "🧹 Removing Jenkins stack (${JENKINS_STACK})..."
  docker stack rm "${JENKINS_STACK}" || true
  echo "🧹 Removing Traefik stack (${TRAEFIK_STACK})..."
  docker stack rm "${TRAEFIK_STACK}" || true
}

status() {
  echo "📦 Docker stacks:"
  docker stack ls
  echo
  echo "🧩 Services (filtered by '${STACK_PREFIX}'):"
  docker service ls --filter name="${STACK_PREFIX}" || true
  echo
  echo "🌐 Network '${NETWORK}':"
  docker network ls --filter name="^${NETWORK}$" --format "Name: {{.Name}}  ID: {{.ID}}"
}

if [ $# -ne 1 ]; then
  usage
fi

case "$1" in
  start)
    ensure_network
    ensure_dirs
    deploy_stacks
    ;;
  stop)
    remove_stacks
    ;;
  restart)
    remove_stacks
    sleep 2
    ensure_network
    ensure_dirs
    deploy_stacks
    ;;
  status)
    status
    ;;
  *)
    usage
    ;;
esac
