#!/usr/bin/env bash
# Hybrid OLED brightness controller.
# Top range  -> hardware backlight (brightnessctl), floored at HW_FLOOR.
# Bottom range -> software dimming via wl-gammarelay-rs (gamma), so the panel
# never runs at the very low hardware levels where OLEDs show a green tint and
# flicker. Falls back to hardware-only if wl-gammarelay isn't running.

STATE="${XDG_RUNTIME_DIR:-/tmp}/oled-brightness"
STEP=5
HW_FLOOR=15     # never drive the panel backlight below this %
CROSS=25        # perceived level at/below which we start dimming in software
SW_MIN=35       # software brightness floor (%), limits banding
SIGNAL=8        # waybar refresh signal (custom/brightness "signal")

sw_set() {  # $1 = percent ; no-op if the gamma daemon isn't up
    busctl --user status rs.wl-gammarelay >/dev/null 2>&1 || return 0
    busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay \
        Brightness d "$(awk "BEGIN{printf \"%.3f\", $1/100}")" >/dev/null 2>&1 || true
}

level=100
[ -f "$STATE" ] && level=$(cat "$STATE" 2>/dev/null || echo 100)

case "${1:-status}" in
    up)   level=$((level + STEP)) ;;
    down) level=$((level - STEP)) ;;
    set)  level=${2:-$level} ;;
esac
(( level > 100 )) && level=100
(( level < 5 ))   && level=5
echo "$level" > "$STATE"

if (( level >= CROSS )); then
    hw=$(( HW_FLOOR + (level - CROSS) * (100 - HW_FLOOR) / (100 - CROSS) ))
    sw=100
else
    hw=$HW_FLOOR
    sw=$(( SW_MIN + level * (100 - SW_MIN) / CROSS ))
fi

brightnessctl -q set "${hw}%"
sw_set "$sw"

# refresh the waybar module after an actual change (not on plain status reads)
[ "${1:-status}" != "status" ] && pkill -RTMIN+$SIGNAL -x waybar 2>/dev/null

icon="󰃞"; (( level >= 34 )) && icon="󰃟"; (( level >= 67 )) && icon="󰃠"
printf '{"text":"%s %d%%","tooltip":"Brightness %d%%  (panel %d%% · gamma %d%%)","percentage":%d}\n' \
    "$icon" "$level" "$level" "$hw" "$sw" "$level"
