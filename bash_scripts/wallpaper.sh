#!/usr/bin/env bash

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [WALLPAPER_DIR]

Randomly change wallpaper using hyprpaper.
Selects a random wallpaper different from the currently loaded one.

Arguments:
    WALLPAPER_DIR    Directory containing wallpapers (optional)
                     Default: \$HOME/Pictures/wallpaper/

Options:
    -h, --help       Show this help message and exit

Example:
    $(basename "$0")
    $(basename "$0") ~/Pictures/my-wallpapers/

EOF
}

# Parse options
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Set wallpaper directory
WALLPAPER_DIR="${1:-$HOME/Pictures/wallpaper/}"

# Validate directory
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: Directory '$WALLPAPER_DIR' does not exist" >&2
    exit 1
fi

# Get current wallpaper
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

# Get a random wallpaper that is not the current one
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)

# Check if wallpaper was found
if [[ -z "$WALLPAPER" ]]; then
    echo "Error: No wallpapers found in '$WALLPAPER_DIR'" >&2
    exit 1
fi

# Apply the selected wallpaper
echo "Setting wallpaper: $WALLPAPER"
# TODO: Нужно как-то получать текущий монитор
conf="eDP-1," 
conf+="$WALLPAPER"
hyprctl hyprpaper wallpaper "$conf"
