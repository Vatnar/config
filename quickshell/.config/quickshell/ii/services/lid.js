// services/lid.js
import Quickshell

QuickShell.bindEvent("lid-close", () => {
    // Lock screen immediately
    QuickShell.exec("swaylock -f && hyprctl dispatch dpms off")
})
