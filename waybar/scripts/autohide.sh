#!/usr/bin/env bash
# Overlap-free Waybar auto-hide (self-correcting).
# Waybar stays in dock mode (reserves its strip while visible, so it never
# covers window content). We drive it to match the cursor:
#   cursor at the very top edge -> visible ; cursor below the bar -> hidden.
#
# Visibility is read from the compositor (the "waybar" layer is present only
# while shown), NOT tracked internally — so a Waybar restart can't invert it.

reveal_zone=3      # px from the top that should reveal the bar
hide_below=46      # px; below this the bar should be hidden
poll=0.2           # seconds between checks

# single instance
pidfile="${XDG_RUNTIME_DIR:-/tmp}/waybar-autohide.pid"
[ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
echo $$ > "$pidfile"

# wait for waybar, then let it install its SIGUSR1 handler (unhandled SIGUSR1
# default-terminates the process, so signalling too early would kill it)
for _ in $(seq 1 50); do pgrep -x waybar >/dev/null && break; sleep 0.2; done
sleep 3

is_visible() { hyprctl layers -j 2>/dev/null | grep -qE '"namespace":[[:space:]]*"waybar"'; }

while true; do
    y=$(hyprctl cursorpos -j 2>/dev/null | grep -o '"y": *[0-9-]*' | grep -o '[0-9-]*$')
    if [ -n "$y" ]; then
        want=-1
        if   [ "$y" -le "$reveal_zone" ]; then want=1   # reveal
        elif [ "$y" -gt "$hide_below"  ]; then want=0   # hide
        fi                                              # else: leave as-is
        if [ "$want" != "-1" ]; then
            if is_visible; then cur=1; else cur=0; fi
            [ "$want" != "$cur" ] && pkill -SIGUSR1 -x waybar 2>/dev/null
        fi
    fi
    sleep "$poll"
done
