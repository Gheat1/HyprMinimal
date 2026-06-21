#!/usr/bin/env bash
# Waybar ASUS performance-profile module (asusctl).
# Usage: profile.sh status  -> prints JSON for waybar
#        profile.sh next    -> cycles to the next profile

icon_for() {
    case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
        quiet|low-power|low_power) echo "󰂠" ;;   # silent
        balanced)                  echo "󰾅" ;;   # balanced
        performance)               echo "󰓅" ;;   # turbo
        *)                         echo "󰈸" ;;
    esac
}

read_profile() {
    # try asusctl first, fall back to the kernel's platform_profile
    local p
    p=$(asusctl profile -p 2>/dev/null | grep -oiE "quiet|balanced|performance|low-power" | head -1)
    [ -z "$p" ] && p=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)
    printf '%s' "${p:-unknown}"
}

case "${1:-status}" in
    next) asusctl profile -n >/dev/null 2>&1 ;;
esac

p=$(read_profile)
icon=$(icon_for "$p")
cls=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
printf '{"text":"%s","tooltip":"Performance profile: %s","class":"%s"}\n' "$icon" "$p" "$cls"
