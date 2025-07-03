#!/usr/bin/env bash

set -euo pipefail

#region Логирование
# Цвета ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_help() {
  cat <<EOF
Usage: $0 [options]

Options:
  -v, --volume        Skip volume cleanup
  -b, --build         Skip build cleanup
  -n, --network       Skip network cleanup
  -c, --container     Skip container cleanup
  -i, --image         Skip image cleanup
  -h, --help          Show this help message
EOF
  exit 0
}
#endregion

while [[ $# -gt 0 ]]; do
  case "$1" in
  -c)
    CONTAINERS=0
    shift 2
    ;;
  -i)
    IMAGES=0
    shift 2
    ;;
  -v)
    VOLUMES=0
    shift 2
    ;;
  -n)
    NETWORKS=0
    shift 2
    ;;
  -b)
    BUILDS=0
    shift 2
    ;;
  -h | --help)
    print_help
    ;;
  *)
    log_error "Неизвестный параметр: $1"
    print_help
    ;;
  esac
done

log_info "Starting Docker cleanup..."

log_info "Size before cleanup:"
docker system df

if [[ ${CONTAINERS:-1} -eq 0 ]]; then
  log_info "Stopping and removing all containers..."
  # shellcheck disable=SC2046
  docker rm $(docker ps -aq)
fi
if [[ ${IMAGES:-1} -eq 0 ]]; then
  log_info "Removing all unused images..."
  # shellcheck disable=SC2046
  docker rmi $(docker images -q)
fi

if [[ ${VOLUMES:-1} -eq 0 ]]; then
  log_info "Removing all unused volumes..."
  docker volume prune -f
fi

if [[ ${NETWORKS:-1} -eq 0 ]]; then
  log_info "Removing all unused networks..."
  docker network prune -f
fi

if [[ ${BUILDS:-1} -eq 0 ]]; then
  log_info "Removing dangling images..."
  docker buildx prune -f
fi

log_info "Size after cleanup:"
docker system df
log_info "Docker cleanup completed."
