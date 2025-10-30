#!/usr/bin/env bash

# Fully silent
exec >/dev/null 2>&1
set +e

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
MATUGEN_DIR="$XDG_CONFIG_HOME/matugen"

WALL_DIR="/home/vatnar/Pictures/wallpapers"

handle_kde_material_you_colors() {
    if [ -f "$SHELL_CONFIG_FILE" ]; then
        enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps' "$SHELL_CONFIG_FILE")
        [ "$enable_qt_apps" = "false" ] && return
    fi
    local kde_scheme_variant=""
    case "$type_flag" in
        scheme-content|scheme-expressive|scheme-fidelity|scheme-fruit-salad|scheme-monochrome|scheme-neutral|scheme-rainbow|scheme-tonal-spot)
            kde_scheme_variant="$type_flag"
            ;;
        *) kde_scheme_variant="scheme-tonal-spot" ;;
    esac
    "$XDG_CONFIG_HOME"/matugen/templates/kde/kde-material-you-colors-wrapper.sh --scheme-variant "$kde_scheme_variant"
}

pre_process() {
    local mode_flag="$1"
    if [[ "$mode_flag" == "dark" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    elif [[ "$mode_flag" == "light" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    fi
    mkdir -p "$CACHE_DIR"/user/generated
}

post_process() {
    handle_kde_material_you_colors &
}

CUSTOM_DIR="$XDG_CONFIG_HOME/hypr/custom"
RESTORE_SCRIPT_DIR="$CUSTOM_DIR/scripts"
RESTORE_SCRIPT="$RESTORE_SCRIPT_DIR/__restore_video_wallpaper.sh"

kill_existing_mpvpaper() {
    pkill -f -9 mpvpaper || true
}

create_restore_script() {
    mkdir -p "$RESTORE_SCRIPT_DIR"
    cat > "$RESTORE_SCRIPT.tmp" << 'EOF'
#!/bin/bash
pkill -f -9 mpvpaper 2>/dev/null || true
EOF
    mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
    chmod +x "$RESTORE_SCRIPT"
}

remove_restore() {
    mkdir -p "$RESTORE_SCRIPT_DIR"
    cat > "$RESTORE_SCRIPT.tmp" << 'EOF'
#!/bin/bash
# placeholder
EOF
    mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
    chmod +x "$RESTORE_SCRIPT"
}

set_wallpaper_path() {
    local path="$1"
    if [ -f "$SHELL_CONFIG_FILE" ]; then
        jq --arg path "$path" '.background.wallpaperPath = $path' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
    fi
}

set_thumbnail_path() {
    local path="$1"
    if [ -f "$SHELL_CONFIG_FILE" ]; then
        jq --arg path "$path" '.background.thumbnailPath = $path' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
    fi
}

pick_random_image() {
    local dir="$1"
    find "$dir" -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 | shuf -z -n 1 | tr -d '\0'
}

get_type_from_config() {
    jq -r '.appearance.palette.type' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "auto"
}

detect_scheme_type_from_image() {
    local img="$1"
    "$SCRIPT_DIR"/scheme_for_image.py "$img" 2>/dev/null | tr -d '\n'
}

switch() {
    imgpath="$1"
    mode_flag="$2"
    type_flag="$3"

    kill_existing_mpvpaper

    matugen_args=(image "$imgpath")
    # Terminal theming disabled: do NOT pass --termscheme and do NOT run applycolor.sh
    generate_colors_material_args=(--path "$imgpath")
    # Optional: still produce cached colors for other consumers if needed
    generate_colors_material_args+=(--cache "$STATE_DIR/user/generated/color.txt")

    set_wallpaper_path "$imgpath"
    remove_restore

    if [[ -z "$mode_flag" ]]; then
        current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
        if [[ "$current_mode" == "prefer-dark" ]]; then
            mode_flag="dark"
        else
            mode_flag="light"
        fi
    fi

    [[ -n "$mode_flag" ]] && matugen_args+=(--mode "$mode_flag") && generate_colors_material_args+=(--mode "$mode_flag")
    [[ -n "$type_flag" ]] && matugen_args+=(--type "$type_flag") && generate_colors_material_args+=(--scheme "$type_flag")

    pre_process "$mode_flag"

    if [ -f "$SHELL_CONFIG_FILE" ]; then
        enable_apps_shell=$(jq -r '.appearance.wallpaperTheming.enableAppsAndShell' "$SHELL_CONFIG_FILE")
        [ "$enable_apps_shell" = "false" ] && return
    fi

    # Generate palette but do not touch terminal theme
    matugen "${matugen_args[@]}" || true

    # If your generate_colors_material.py or applycolor.sh affects terminal, they are skipped.
    # Leave them commented/removed intentionally to avoid terminal changes.
    # source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" || true
    # python3 "$SCRIPT_DIR/generate_colors_material.py" "${generate_colors_material_args[@]}" > "$STATE_DIR"/user/generated/material_colors.scss || true
    # "$SCRIPT_DIR"/applycolor.sh || true
    # deactivate || true

    max_width_desired="$(hyprctl monitors -j | jq '([.[].width] | min)' | xargs)"
    max_height_desired="$(hyprctl monitors -j | jq '([.[].height] | min)' | xargs)"
    post_process "$max_width_desired" "$max_height_desired" "$imgpath"
}

main() {
    imgpath=""
    mode_flag=""
    type_flag=""
    color_flag=""
    color=""
    noswitch_flag=""

    type_flag="$(get_type_from_config)"
    allowed_types=(scheme-content scheme-expressive scheme-fidelity scheme-fruit-salad scheme-monochrome scheme-neutral scheme-rainbow scheme-tonal-spot auto)

    imgpath="$(pick_random_image "$WALL_DIR")"
    [ -z "$imgpath" ] && exit 0

    if [[ "$type_flag" == "auto" ]]; then
        detected_type="$(detect_scheme_type_from_image "$imgpath")"
        for t in "${allowed_types[@]}"; do
            if [[ "$detected_type" == "$t" && "$detected_type" != "auto" ]]; then
                type_flag="$detected_type"
                break
            fi
        done
        [ "$type_flag" = "auto" ] && type_flag="scheme-tonal-spot"
    fi

    switch "$imgpath" "$mode_flag" "$type_flag" "$color_flag" "$color"
}

create_restore_script
main

