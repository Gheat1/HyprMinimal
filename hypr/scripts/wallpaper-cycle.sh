#!/usr/bin/env bash
# Rotate minimalist wallpapers every 5 min; SIGUSR1 (Super+W) skips to the
# next one immediately. Started from hyprland.lua autostart; flock = single
# instance.
#
# hyprpaper 0.8's native directory cycling can't be nudged from outside (its
# only IPC request replaces the cycle state entirely), so hyprpaper.conf holds
# one static image and this script owns the rotation via
# `hyprctl hyprpaper wallpaper "[mon],[path]"`.
#
# The monitor MUST be an explicit output name: hyprpaper matches explicit
# states first, then falls back to the FIRST wildcard — which is always the
# conf's `monitor = *` entry, so empty-monitor IPC requests are accepted but
# never displayed ("*" itself is rejected by the IPC as an invalid monitor).

dir="$HOME/.local/share/wallpapers/minimal"
interval=300

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/wallpaper-cycle.lock"
flock -n 9 || exit 0

mapfile -t wps < <(printf '%s\n' "$dir"/*.png)
(( ${#wps[@]} )) || exit 1

trap ':' USR1   # interrupts `wait` below -> advance now

set_wallpaper() {
    local mon
    for mon in $(hyprctl monitors | awk '/^Monitor/{print $2}'); do
        hyprctl hyprpaper wallpaper "${mon},$1" >/dev/null 2>&1
    done
}

# wait for hyprpaper's IPC to come up on session start (the empty-monitor
# request is a no-op display-wise — the conf shows wps[0] at startup anyway —
# but it only succeeds once hyprpaper is serving)
until hyprctl hyprpaper wallpaper ",${wps[0]}" >/dev/null 2>&1; do sleep 1; done

i=1
while :; do
    # 9>&- : don't let sleep inherit the lock fd — an orphaned sleep would
    # otherwise hold the flock after this script dies, blocking restarts
    sleep "$interval" 9>&- &
    sp=$!
    wait "$sp"
    skipped=$(( $? > 128 ))   # wait interrupted by SIGUSR1 = manual skip
    kill "$sp" 2>/dev/null
    set_wallpaper "${wps[i]}"
    # feedback only on manual skips — the wallpapers are subtle by design and
    # a Super+W press would otherwise look like it did nothing
    (( skipped )) && notify-send -a wallpaper -t 2000 "Wallpaper" "$(basename "${wps[i]}" .png)"
    i=$(( (i + 1) % ${#wps[@]} ))
done
