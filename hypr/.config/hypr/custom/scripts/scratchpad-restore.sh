#!/usr/bin/env bash

TMP_FILE="/tmp/last_ws_for_scratchpad"

# Get active window ID
WIN_ID=$(hyprctl activewindow -j | jq -r '.id')

# Get the active window's current workspace
WIN_WS=$(hyprctl clients -j | jq -r ".[] | select(.id==$WIN_ID) | .workspace.id")

# Check if the window is already in scratchpad
if [ "$WIN_WS" = "-99" ]; then
    # Restore to previous workspace
    if [ -f "$TMP_FILE" ]; then
        LAST_WS=$(cat "$TMP_FILE")
        notify-send "Restoring window from scratchpad to workspace $LAST_WS"
        hyprctl togglespecialworkspace           # Go to scratchpad
        hyprctl movetoworkspace,$LAST_WS        # Move back to original workspace
        hyprctl workspace,$LAST_WS              # Focus that workspace
    else
        notify-send "No previous workspace info found, cannot restore"
    fi
else
    # Send window to scratchpad
    notify-send "Sending window to scratchpad"
    echo "$WIN_WS" > "$TMP_FILE"
    hyprctl movetoworkspace,-99               # Move window to scratchpad
fi
