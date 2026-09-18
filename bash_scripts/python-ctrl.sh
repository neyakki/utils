#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
die() { log_error "$1"; exit 1; }

print_help() {
  cat <<EOF
Usage: $(basename "$0") <install|delete> -v <X.Y>

Commands:
  install              Install the latest patch version of Python X.Y from source
  delete               Delete Python X.Y

Options:
  -v, --version        Python version, e.g. 3.12
  -h, --help           Show this help

Logs are written to /var/log/python-install.log
EOF
}

[[ $# -ge 1 ]] || { print_help >&2; exit 1; }
ACTION=$1
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
  -v | --version)
    [[ $# -ge 2 ]] || die "Параметру $1 нужно значение, например: $1 3.12"
    VERSION=$2
    shift 2
    ;;
  -h | --help)
    print_help
    exit 0
    ;;
  *)
    die "Неизвестный параметр: $1"
    ;;
  esac
done

case "$ACTION" in
install | delete) ;;
*) die "Неизвестная команда: $ACTION (install или delete)" ;;
esac

[[ ${VERSION:-} =~ ^[0-9]+\.[0-9]+$ ]] || die "Укажите версию X.Y, например: $(basename "$0") $ACTION -v 3.12"

[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$ACTION" --version "$VERSION"

LOG="/var/log/python-install.log"
exec > >(tee -a "$LOG") 2>&1
echo "=== $(date '+%F %T') $ACTION $VERSION ==="

PREFIX="/opt/python/python$VERSION"
BIN_PATH="/usr/local/bin"
LIB_PATH="/usr/local/lib"

install() {
  for tool in cc make; do command -v "$tool" >/dev/null || die "Нет '$tool'. Сначала: sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev libreadline-dev libsqlite3-dev"; done

  log_info "Поиск последней версии Python $VERSION.x..."
  latest=$(
    curl -sf https://www.python.org/ftp/python/ |
      grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' |
      grep "^$VERSION\." |
      sort -V |
      tail -n 1
  ) || true
  [ -n "${latest:-}" ] || die "Python $VERSION.x не найден на python.org"
  log_info "Найдена версия: $latest"

  build=$(mktemp -d /tmp/python-build.XXXXXX)
  trap 'rm -rf "$build"' EXIT
  log_info "Создание директории сборки: $build"

  cd "$build"
  log_info "Скачивание Python-$latest.tgz"
  curl -fO "https://www.python.org/ftp/python/$latest/Python-$latest.tgz"
  log_info "Распаковка архива"
  tar xzf "Python-$latest.tgz"
  cd "Python-$latest"

  log_info "Очистка предыдущей установки $PREFIX"
  rm -rf "$PREFIX"
  log_info "Конфигурация ./configure"
  ./configure --prefix="$PREFIX" --enable-optimizations --with-lto --enable-shared
  log_info "Компиляция (make -j $(nproc))"
  make -j "$(nproc)"
  log_info "Установка (make altinstall)"
  make altinstall

  log_info "Копирование libpython$VERSION.so.1.0 в $LIB_PATH и обновление кэша ldconfig"
  cp "$PREFIX/lib/libpython$VERSION.so.1.0" "$LIB_PATH/"
  ldconfig
  log_info "Создание симлинков python$VERSION и pip$VERSION в $BIN_PATH"
  ln -sf "$PREFIX/bin/python$VERSION" "$BIN_PATH/python$VERSION"
  ln -sf "$PREFIX/bin/pip$VERSION" "$BIN_PATH/pip$VERSION"

  log_info "Очистка временной директории"
  log_info "Установка Python $latest завершена"
}

delete() {
  log_info "Удаление $PREFIX"
  rm -rf "$PREFIX"
  log_info "Удаление libpython из $LIB_PATH и симлинков из $BIN_PATH"
  rm -f "$LIB_PATH/libpython$VERSION.so.1.0" "$LIB_PATH/libpython$VERSION.so.1" "$BIN_PATH/python$VERSION" "$BIN_PATH/pip$VERSION"
  log_info "Обновление кэша ldconfig"
  ldconfig
  log_info "Python $VERSION удален"
}

if [[ "$ACTION" == "delete" ]]; then
  log_warning "Вы собираетесь удалить Python $VERSION ($PREFIX)"
  read -rp "Удалить? (yes/no) " answer
  if [[ "$answer" =~ ^[yY]([eE][sS])?$ ]]; then
    delete
  else
    log_info "Отмена."
  fi
else
  install
fi
