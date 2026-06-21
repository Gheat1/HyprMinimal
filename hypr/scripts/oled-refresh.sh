#!/usr/bin/env bash
# OLED pixel-refresh wash.
# Cycles the whole screen through full R/G/B + white/black for a set time so
# every pixel and subpixel runs across its range, evening out wear.
# Meant to run in a fullscreen terminal. Usage: oled-refresh.sh [seconds]

dur=${1:-30}

# R;G;B fills: black, white, red, green, blue, mid-grey
colors=("0;0;0" "255;255;255" "255;0;0" "0;255;0" "0;0;255" "128;128;128")

cleanup() { printf '\e[0m\e[2J\e[H'; tput cnorm 2>/dev/null; clear; }
trap cleanup EXIT INT TERM

tput civis 2>/dev/null    # hide cursor
end=$((SECONDS + dur))
i=0
while [ $SECONDS -lt $end ]; do
    c=${colors[$((i % ${#colors[@]}))]}
    printf '\e[48;2;%sm\e[2J\e[H' "$c"   # set bg colour, clear whole screen
    sleep 0.1
    i=$((i + 1))
done
