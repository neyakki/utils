#!/usr/bin/env bash

print_help() {
  cat <<EOF
Usage: $(basename "$0") <command> 

Command:
    enable           Enable sunset
    disable          Disable sunset
EOF

  exit 0
}

if [[ -z $1 ]]; then
    echo "Не передана команда"
    print_help
fi

case "$1" in
    enable)
        hyprctl hyprsunset temperature 5500 > /dev/null
        hyprctl hyprsunset gamma 80 > /dev/null
        ;;
    disable)
        hyprctl hyprsunset identity > /dev/null
        hyprctl hyprsunset gamma 100 > /dev/null
        ;;
    *)
        echo "Неизвестный параметр: $1"
        print_help
        ;;
esac

