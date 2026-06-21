#!/usr/bin/env bash
# Hardware backlight control for the OLED panel (intel_backlight).
# No gamma daemon (that caused the black-screen-on-wake). Goes down to MIN% so
# you can get dark for night use; stop dimming before the green tint appears.
# Usage: brightness.sh status | up | down

BL=/sys/class/backlight/intel_backlight
MIN=1          # lowest allowed % (avoid 0 = black). Raise if green appears too soon.
STEP=5
SIGNAL=8       # waybar custom/brightness "signal"

max=$(cat "$BL/max_brightness")
cur=$(cat "$BL/brightness")
pct=$(( (cur * 100 + max / 2) / max ))

case "${1:-status}" in
    up)   pct=$((pct + STEP)) ;;
    down) pct=$((pct - STEP)) ;;
esac
(( pct > 100 )) && pct=100
(( pct < MIN )) && pct=MIN

if [ "${1:-status}" != "status" ]; then
    brightnessctl -q set "${pct}%"
    pkill -RTMIN+$SIGNAL -x waybar 2>/dev/null
fi

icon="󰃞"; (( pct >= 34 )) && icon="󰃟"; (( pct >= 67 )) && icon="󰃠"
printf '{"text":"%s %d%%","tooltip":"Brightness %d%%","percentage":%d}\n' "$icon" "$pct" "$pct" "$pct"
