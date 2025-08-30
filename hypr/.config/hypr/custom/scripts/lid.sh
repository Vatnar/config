#!/usr/bin/env bash
# Adjust names if needed
INTEL="eDP-1"
EXTERNAL=$(hyprctl monitors | grep -oP 'DP-[0-9]+' | head -n1)

if [[ "$1" == "close" ]]; then
  if [[ -n "$EXTERNAL" ]]; then
    hyprctl keyword monitor "$INTEL, disable"
  else
    systemctl suspend
  fi
elif [[ "$1" == "open" ]]; then
  hyprctl keyword monitor "$INTEL, preferred, auto, 1"
  hyprctl reload
fi
