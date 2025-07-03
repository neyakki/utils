#!/usr/bin/env bash

set -euo pipefail

#region Logging
# ANSI colors
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

Cleans up Docker resources. With no options, will prompt to clean everything.

Options:
  -c, --container     Clean up containers
  -i, --image         Clean up images
  -v, --volume        Clean up volumes
  -n, --network       Clean up networks
  -b, --build         Clean up build cache
  -s, --system        Run system-wide cleanup (includes volumes)
  -a, --all           Clean up everything (no prompting)
  -h, --help          Show this help message
EOF
  exit 0
}
#endregion

# Default values - 1 means do not clean
CONTAINERS=1
IMAGES=1
VOLUMES=1
NETWORKS=1
BUILDS=1
SYSTEM_CACHE=1
CLEAN_ALL=1

while [[ $# -gt 0 ]]; do
  case "$1" in
  -c | --container)
    CONTAINERS=0
    shift 1
    ;;
  -i | --image)
    IMAGES=0
    shift 1
    ;;
  -v | --volume)
    VOLUMES=0
    shift 1
    ;;
  -n | --network)
    NETWORKS=0
    shift 1
    ;;
  -b | --build)
    BUILDS=0
    shift 1
    ;;
  -s | --system)
    SYSTEM_CACHE=0
    shift 1
    ;;
  -a | --all)
    CLEAN_ALL=0
    shift 1
    ;;
  -h | --help)
    print_help
    ;;
  *)
    log_error "Unknown parameter: $1"
    print_help
    exit 1
    ;;
  esac
done

clean_container() {
  if [[ ${CONTAINERS} -eq 0 ]]; then
    log_info "Stopping and removing all containers..."
    if docker ps -q &>/dev/null; then
      log_info "Stopping containers first..."
      # shellcheck disable=SC2046
      docker stop $(docker ps -q) &>/dev/null || log_warning "No running containers to stop"
    fi
    
    if docker ps -aq &>/dev/null; then
      # shellcheck disable=SC2046
      docker rm $(docker ps -aq) &>/dev/null || log_warning "No containers to remove"
      log_info "Containers removed successfully"
    else
      log_info "No containers found to remove"
    fi
  fi
}

clean_images() {
  if [[ ${IMAGES} -eq 0 ]]; then
    log_info "Removing all unused images..."
    if docker images -q &>/dev/null; then
      # shellcheck disable=SC2046
      docker rmi $(docker images -q) &>/dev/null || log_warning "Failed to remove some images"
      log_info "Images removed successfully"
    else
      log_info "No images found to remove"
    fi
  fi
}

clean_volumes() {
  if [[ ${VOLUMES} -eq 0 ]]; then
    log_info "Removing all unused volumes..."
    docker volume prune -f &>/dev/null || log_warning "Failed to remove some volumes"
    log_info "Volumes pruned successfully"
  fi
}

clean_networks() {
  if [[ ${NETWORKS} -eq 0 ]]; then
    log_info "Removing all unused networks..."
    docker network prune -f &>/dev/null || log_warning "Failed to remove some networks"
    log_info "Networks pruned successfully"
  fi
}

clean_builds() {
  if [[ ${BUILDS} -eq 0 ]]; then
    log_info "Removing dangling images and build cache..."
    docker buildx prune -f &>/dev/null || log_warning "Failed to prune build cache"
    log_info "Build cache pruned successfully"
  fi
}

clean_system_cache() {
  if [[ ${SYSTEM_CACHE} -eq 0 ]]; then
    log_info "Running system-wide cache cleanup..."
    docker system prune -af --volumes &>/dev/null || log_warning "Failed to completely clean system cache"
    log_info "System cache cleaned successfully"
  fi
}

# Check if Docker is running
if ! docker info &>/dev/null; then
  log_error "Docker is not running. Please start Docker and try again."
  exit 1
fi

log_info "Starting Docker cleanup..."

log_info "Size before cleanup:"
docker system df

# Set all cleanup flags if --all option was specified
if [[ $CLEAN_ALL -eq 0 ]]; then
  CONTAINERS=0
  IMAGES=0
  VOLUMES=0
  NETWORKS=0
  BUILDS=0
  SYSTEM_CACHE=0
fi

# If no specific cleanup was requested, ask to clean everything
if [[ $CONTAINERS -eq 1 ]] && [[ $IMAGES -eq 1 ]] && \
   [[ $VOLUMES -eq 1 ]] && [[ $NETWORKS -eq 1 ]] && \
   [[ $BUILDS -eq 1 ]] && [[ $SYSTEM_CACHE -eq 1 ]] && \
   [[ $CLEAN_ALL -eq 1 ]]; then
  
  read -rp "Clean ALL Docker resources? [y/N] " -n 1 REPLY
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    CONTAINERS=0
    IMAGES=0
    VOLUMES=0
    NETWORKS=0
    BUILDS=0
    SYSTEM_CACHE=0
  else
    log_info "No cleanup performed."
    exit 0
  fi
fi

# Run the cleanup functions
clean_container
clean_images
clean_networks
clean_volumes
clean_builds
clean_system_cache

log_info "Size after cleanup:"
docker system df
log_info "Docker cleanup completed successfully."
