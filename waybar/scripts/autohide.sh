#!/usr/bin/env bash
# Overlap-free Waybar auto-hide.
# Waybar stays in dock mode (reserves its strip while visible, so it never
# covers window content). We toggle it with SIGUSR1 only when the cursor
# CROSSES a threshold — edge-triggered, so it can never strobe.
#
#   cursor at the very top edge -> reveal ; cursor below the bar -> hide.
#
# State is tracked internally but resynced whenever waybar restarts (a fresh
# waybar is always visible), so it can't get stuck inverted.

reveal_zone=3      # px from the top that reveals the bar
hide_below=46      # px; below this the bar hides
poll=0.2

# single instance
pidfile="${XDG_RUNTIME_DIR:-/tmp}/waybar-autohide.pid"
[ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
echo $$ > "$pidfile"

# wait for waybar, then settle (unhandled SIGUSR1 default-kills the process,
# so we must not signal before its handler is installed)
for _ in $(seq 1 50); do pgrep -x waybar >/dev/null && break; sleep 0.2; done
sleep 3

wpid=$(pgrep -x waybar | head -1)
pkill -SIGUSR1 -x waybar 2>/dev/null   # waybar starts visible -> hide it
shown=0
want=0

while true; do
    # if waybar was restarted, it's visible again — resync without toggling
    npid=$(pgrep -x waybar | head -1)
    if [ -n "$npid" ] && [ "$npid" != "$wpid" ]; then
        wpid=$npid
        sleep 3
        shown=1
    fi

    y=$(hyprctl cursorpos -j 2>/dev/null | grep -o '"y": *[0-9-]*' | grep -o '[0-9-]*$')
    if [ -n "$y" ]; then
        if   [ "$y" -le "$reveal_zone" ]; then want=1
        elif [ "$y" -gt "$hide_below"  ]; then want=0
        fi
        if [ "$want" != "$shown" ]; then
            pkill -SIGUSR1 -x waybar 2>/dev/null
            shown=$want
        fi
    fi
    sleep "$poll"
done
