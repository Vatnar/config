#!/bin/bash

# Get the list of connected monitor names
connected_monitors=$(hyprctl -j monitors | jq -r '.[].name')

if echo "$connected_monitors" | grep -q "HDMI-A-1" && \
   echo "$connected_monitors" | grep -q "DP-1"; then
    # Both HDMI and DP are connected → disable internal panel
    hyprctl keyword monitor "eDP-1,disable"
else
    # Otherwise keep eDP-1 as main at 1920x1080@144
    hyprctl keyword monitor "eDP-1,1920x1080@144,0x0,1"
fi

