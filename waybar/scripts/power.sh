#!/usr/bin/env bash
# Waybar unified power module.
# One section for every battery-powered thing: the laptop, Logitech dongle
# devices (via Solaar, e.g. MX Master), and connected Bluetooth devices
# (via BlueZ, e.g. Skullcandy Crusher ANC 2).
#
# The bar shows only ICONS; hover to see each device's percentage.
# Usage: power.sh   -> prints JSON for waybar

# --- battery-level glyph for the laptop -------------------------------------
laptop_icon() {
    local pct="$1" charging="$2"
    [ "$charging" = "1" ] && { echo "󰂄"; return; }
    local ramp=("󰂎" "󰁺" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹")
    local idx=$(( pct * (${#ramp[@]} - 1) / 100 ))
    [ "$idx" -lt 0 ] && idx=0
    [ "$idx" -ge "${#ramp[@]}" ] && idx=$(( ${#ramp[@]} - 1 ))
    echo "${ramp[$idx]}"
}

# --- device-type glyph from a name/kind -------------------------------------
dev_icon() {
    case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
        *headphone*|*headset*|*earbud*|*buds*|*crusher*|*anc*|*audio*) echo "󰋋" ;;
        *mouse*|*mx*)                        echo "󰍽" ;;
        *keyboard*|*keychron*|*keys*)        echo "󰌌" ;;
        *controller*|*gamepad*)              echo "󰊴" ;;
        *)                                   echo "󰂱" ;;
    esac
}

icons=()
tips=()
min=101
declare -A seen   # de-dupe devices that report battery more than once

add_dev() {   # add_dev <icon> <name> <pct>
    local key
    key=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
    [ -n "${seen[$key]}" ] && return
    seen[$key]=1
    icons+=("$1")
    tips+=("$2: $3%")
    [ "$3" -lt "$min" ] && min="$3"
}

# --- laptop battery ---------------------------------------------------------
lbat=$(upower -e 2>/dev/null | grep -m1 -iE "battery_BAT")
if [ -n "$lbat" ]; then
    info=$(upower -i "$lbat" 2>/dev/null)
    pct=$(printf '%s' "$info" | grep -m1 percentage | grep -oE '[0-9]+' | head -1)
    state=$(printf '%s' "$info" | grep -m1 state | awk '{print $2}')
    if [ -n "$pct" ]; then
        chg=0; { [ "$state" = "charging" ] || [ "$state" = "fully-charged" ]; } && chg=1
        icons+=("$(laptop_icon "$pct" "$chg")")
        tips+=("Laptop: $pct%")
        seen[laptop]=1
        [ "$chg" = "0" ] && [ "$pct" -lt "$min" ] && min="$pct"
    fi
fi

# --- Logitech dongle devices via Solaar -------------------------------------
# solaar can only read the HID device one caller at a time; an occasional
# collision returns nothing, so we cache the last good read to avoid flicker.
if command -v solaar >/dev/null 2>&1; then
    cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-power-solaar"
    parsed=$(timeout 12 solaar show 2>/dev/null | awk '
        /^  [0-9]+: /            { name=$0; sub(/^  [0-9]+: /,"",name); kind=""; }
        /^ *Kind *: /            { kind=$0; sub(/.*: */,"",kind) }
        /Battery: *[0-9]+%/      { b=$0; sub(/.*Battery: */,"",b); sub(/%.*/,"",b);
                                   print kind "|" name "|" b }
    ')
    if [ -n "$parsed" ]; then
        printf '%s\n' "$parsed" > "$cache"
    elif [ -f "$cache" ]; then
        parsed=$(cat "$cache")
    fi
    while IFS='|' read -r kind name pct; do
        [ -z "$pct" ] && continue
        add_dev "$(dev_icon "${kind}${name}")" "${name:-Logitech}" "$pct"
    done <<< "$parsed"
fi

# --- connected Bluetooth devices via BlueZ ----------------------------------
for mac in $(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); do
    binfo=$(bluetoothctl info "$mac" 2>/dev/null)
    name=$(printf '%s' "$binfo" | grep -m1 "Name:" | cut -d' ' -f2-)
    [ -z "$name" ] && name="$mac"
    pct=$(printf '%s' "$binfo" | grep -i "Battery Percentage" \
          | grep -oE '\([0-9]+\)' | tr -d '()' | head -1)
    if [ -z "$pct" ]; then
        up=$(upower -e 2>/dev/null | grep -iE "$(printf '%s' "$mac" | tr ':' '_')")
        [ -n "$up" ] && pct=$(upower -i "$up" 2>/dev/null \
              | grep -i percentage | grep -oE '[0-9]+' | head -1)
    fi
    if [ -n "$pct" ]; then
        add_dev "$(dev_icon "$name")" "$name" "$pct"
    fi
done

# --- emit -------------------------------------------------------------------
if [ "${#icons[@]}" -eq 0 ]; then
    printf '{"text":"","tooltip":""}\n'
    exit 0
fi

text=$(printf '%s  ' "${icons[@]}"); text=${text%  }
tooltip=$(printf '%s\\n' "${tips[@]}"); tooltip=${tooltip%\\n}

cls="normal"
[ "$min" -le 20 ] && cls="warning"
[ "$min" -le 10 ] && cls="critical"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$cls"
