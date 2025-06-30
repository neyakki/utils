#!/bin/bash

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
    echo "Usage: $0 <command> -v <version>"
    echo
    echo "Command:"
    echo "delete              Delete python"
    echo "install             Install python"
    echo
    echo "Args:"
    echo "  -v, --version     Python version"
    echo "  -h, --help"
    exit 0
}
#endregion

#region Основная логика
install() {
    # Поиск последней версии Python и скачивание
    log_info "Поиск последней версии Python $VERSION_PREFIX.x..."
    LATEST_VERSION=$(
        curl -s https://www.python.org/ftp/python/ | \
        grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' | \
        grep "^$VERSION_PREFIX\." | \
        sort -t. -k1,1n -k2,2n -k3,3n | \
        tail -n 1
    )

    if [[ -z "$LATEST_VERSION" ]]; then
        log_warning "Не удалось найти версию Python $VERSION_PREFIX.x"
        exit 2
    fi

    log_info "Найдена версия: $LATEST_VERSION"
    FILENAME="Python-$LATEST_VERSION"
    TGZ="$FILENAME.tgz"
    URL="https://www.python.org/ftp/python/$LATEST_VERSION/$TGZ"

    cd /tmp
    log_info "Скачиваем: $URL"
    curl -O "$URL"

    # Конфигурация и сборка
    log_info "Распаковка архива $TGZ"
    tar xzf "$TGZ"
    cd "$FILENAME"

    if [[ -d "$PYTHON_DIR" ]]; then
        log_info "Очистка существующей директории $PYTHON_DIR"
        rm -rf "$PYTHON_DIR"
        rm -f "$LIB_PATH/libpython$VERSION_PREFIX.so.1.0"
        rm -f "$BIN_PATH/python$VERSION_PREFIX"
    fi

    log_info "Создание директории $PYTHON_DIR"
    sudo mkdir -p "$PYTHON_DIR"

    log_info "Конфигурация и компиляция Python $LATEST_VERSION..."
    echo "configure:\n" | sudo tee /tmp/configure.log > /dev/null
    ./configure \
    --prefix="$PYTHON_DIR" \
    --enable-optimizations \
    --with-lto \
    --enable-shared 2>&1 | sudo tee /tmp/configure.log > /dev/null

    CPU_CORES=$(nproc || grep -c ^processor /proc/cpuinfo)
    echo "make:\n" | sudo tee /tmp/configure.log > /dev/null
    make -j "$CPU_CORES" 2>&1 | sudo tee /tmp/configure.log > /dev/null
    echo "altinstall:\n" | sudo tee /tmp/configure.log > /dev/null
    make altinstall 2>&1 | sudo tee /tmp/configure.log > /dev/null

    log_info "Создание симлинков и копирование библиотек"
    cp "$PYTHON_DIR/lib/libpython$VERSION_PREFIX.so.1.0" "$LIB_PATH"
    ln -sf "$PYTHON_DIR/bin/python$VERSION_PREFIX" "$BIN_PATH/python$VERSION_PREFIX"
    ln -sf "$PYTHON_DIR/bin/pip$VERSION_PREFIX" "$BIN_PATH/pip$VERSION_PREFIX"

    # Завершающая очистка
    log_info "Очистка временных файлов"
    rm -rf "/tmp/$TGZ" "/tmp/$FILENAME"

    log_info "Установка Python $LATEST_VERSION завершена"
}

delete() {
    log_info "Удаленние python версии $RAW_VERSION"
    if [ -d $PYTHON_DIR ]; then
        rm -rf $PYTHON_DIR
    fi
    if [ -a "$LIB_PATH/libpython$VERSION_PREFIX.so.1.0" ]; then
        rm "$LIB_PATH/libpython$VERSION_PREFIX.so.1.0"
    fi
    if [ -a "$BIN_PATH/python$VERSION_PREFIX" ]; then
        rm "$BIN_PATH/python$VERSION_PREFIX"
    fi
    if [ -a "$BIN_PATH/pip$VERSION_PREFIX" ]; then
        rm "$BIN_PATH/pip$VERSION_PREFIX"
    fi
    log_info "Python удален"
}
#endregion

ACTION=$1
shift 1

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--version)
            RAW_VERSION="$2"
            shift 2
        ;;
        -h|--help)
            print_help
        ;;
        *)
            log_error "Неизвестный параметр: $1"
            print_help
        ;;
    esac
done

# Настройки
if [[ "$RAW_VERSION" =~ \. ]]; then
    VERSION_PREFIX=$RAW_VERSION
else
    MAJOR="${RAW_VERSION:0:1}"
    MINOR="${RAW_VERSION:1}"
    VERSION_PREFIX="${MAJOR}.${MINOR}"
fi

ROOT_PATH="/usr/local"
BIN_PATH="$ROOT_PATH/bin"
LIB_PATH="$ROOT_PATH/lib"
PYTHON_BASE_DIR="/opt/python"
PYTHON_DIR="$PYTHON_BASE_DIR/python$RAW_VERSION"

if [ $ACTION == "delete" ]; then
    log_warning "Вы хотите удалить файл? (yes/no)"
    read answer
    case "$answer" in
        [yY]|[yY][eE][sS] )
            delete
            ;;
        * )
            echo "Отмена."
            ;;
    esac
else
    install
fi