#!/bin/bash
hyprctl events | while read -r line; do
    if [[ "$line" =~ "monitor" ]]; then
        ~/.local/bin/monitor-setup.sh
    fi
done

