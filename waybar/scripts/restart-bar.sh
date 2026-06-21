#!/usr/bin/env bash
# Cleanly restart waybar + the auto-hide watcher, synced. Bound to Super+Shift+B.
pkill -f autohide.sh 2>/dev/null
killall waybar 2>/dev/null
sleep 1
setsid -f waybar >/dev/null 2>&1
sleep 4
setsid -f "$HOME/.config/waybar/scripts/autohide.sh" >/dev/null 2>&1
