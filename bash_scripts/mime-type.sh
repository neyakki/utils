#!/usr/bin/env bash

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
Usage: $0 <command> -f <desktop-file>

Options:
  -f, --file       Path to desktop file
  -h, --help       Show this help message
EOF

  exit 0
}
#endregion

while [[ $# -gt 0 ]]; do
  case "$1" in
  -f | --file)
    file="$2"
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

desktop="${file##*/}"

mime_line=$(grep MimeType $file)

# Удаляем "MimeType=" и последнюю точку с запятой, затем разбиваем
mime_types=$(echo "$mime_line" | sed 's/MimeType=//' | sed 's/;$//')

# Цикл по всем MIME-типам
for mime_type in $(echo "$mime_types" | tr ';' ' '); do
    log_info "Обрабатываем: $mime_type"
    xdg-mime default "$desktop" "$mime_type"
done

log_info "Для форматов установлено приложение по умолчанию ${desktop}"
