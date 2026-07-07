#!/usr/bin/env bash
# Waybar low-power mode for the Zephyrus G16 (custom/lowpower).
# Usage: lowpower.sh status | toggle | on | off
#
# ON bundles: Quiet fan profile, EPP=power, turbo boost off, panel to 60Hz,
# animations+blur off, keyboard backlight off, OLED dimmed to <=DIM_PCT%.
# OFF restores exactly what was saved when it was enabled.
# State file existing = mode is on (runtime dir, so a reboot resets to off,
# which matches sysfs/hyprland defaults coming back on their own).

STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-lowpower.state"
SIGNAL=9            # this module's waybar "signal" (brightness.sh uses 8)
BL=/sys/class/backlight/intel_backlight
PSTATE=/sys/devices/system/cpu/intel_pstate
DIM_PCT=40

# The Lua config disables hyprctl keyword; use eval with hl.* calls instead.
# hl.config() merges partial tables, so these only touch what they name.
set_panel() {  # set_panel <refresh>  — keep position/scale in sync with hyprland.lua
    hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"2560x1600@$1\", position = \"0x0\", scale = 1.6 })" >/dev/null
}
set_anim() { hyprctl eval "hl.config({ animations = { enabled = $1 } })" >/dev/null; }
set_blur() { hyprctl eval "hl.config({ decoration = { blur = { enabled = $1 } } })" >/dev/null; }

opt_bool() {  # getoption as 1/0
    hyprctl getoption "$1" 2>/dev/null | awk '
        /int:/  { print $2; exit }
        /bool:/ { print ($2 == "true") ? 1 : 0; exit }'
}
as_lua() { [ "${1:-1}" = 0 ] && echo false || echo true; }

read_profile() {
    local p
    p=$(asusctl profile -p 2>/dev/null | grep -oiE "quiet|balanced|performance" | head -1)
    [ -z "$p" ] && p=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)
    printf '%s' "${p:-balanced}"
}

set_epp() {
    local f
    for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "$1" > "$f" 2>/dev/null
    done
}

refresh_bar() {
    pkill -RTMIN+$SIGNAL -x waybar 2>/dev/null
    pkill -RTMIN+8 -x waybar 2>/dev/null   # brightness module
}

lp_on() {
    [ -f "$STATE" ] && return
    local max cur pct
    max=$(cat "$BL/max_brightness"); cur=$(cat "$BL/brightness")
    pct=$(( (cur * 100 + max / 2) / max ))
    {
        echo "PROFILE=$(read_profile)"
        echo "EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
        echo "NO_TURBO=$(cat $PSTATE/no_turbo)"
        echo "BRIGHTNESS=$cur"
        echo "KBD=$(brightnessctl -d asus::kbd_backlight get 2>/dev/null || echo 0)"
        echo "ANIM=$(opt_bool animations:enabled)"
        echo "BLUR=$(opt_bool decoration:blur:enabled)"
    } > "$STATE"

    asusctl profile -P Quiet >/dev/null 2>&1
    set_epp power
    echo 1 > "$PSTATE/no_turbo" 2>/dev/null
    set_panel 60
    set_anim false
    set_blur false
    brightnessctl -d asus::kbd_backlight -q set 0 2>/dev/null
    (( pct > DIM_PCT )) && brightnessctl -d intel_backlight -q set "${DIM_PCT}%"
}

lp_off() {
    [ -f "$STATE" ] || return
    # shellcheck source=/dev/null
    . "$STATE"
    asusctl profile -P "${PROFILE^}" >/dev/null 2>&1
    set_epp "${EPP:-balance_performance}"
    echo "${NO_TURBO:-0}" > "$PSTATE/no_turbo" 2>/dev/null
    set_panel 240
    set_anim "$(as_lua "$ANIM")"
    set_blur "$(as_lua "$BLUR")"
    brightnessctl -d asus::kbd_backlight -q set "${KBD:-0}" 2>/dev/null
    [ -n "$BRIGHTNESS" ] && brightnessctl -d intel_backlight -q set "$BRIGHTNESS"
    rm -f "$STATE"
}

case "${1:-status}" in
    on)     lp_on;  refresh_bar ;;
    off)    lp_off; refresh_bar ;;
    toggle) if [ -f "$STATE" ]; then lp_off; else lp_on; fi; refresh_bar ;;
esac

if [ -f "$STATE" ]; then
    printf '{"text":"󰌪","tooltip":"Low-power mode: ON\\nQuiet · 60Hz · turbo off · EPP power · dimmed\\nClick to restore","class":"on"}\n'
else
    printf '{"text":"󰌪","tooltip":"Low-power mode: off\\nClick for Quiet · 60Hz · turbo off · EPP power","class":"off"}\n'
fi
