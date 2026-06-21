#!/usr/bin/env bash
# Overlap-free Waybar auto-hide.
# Waybar stays in dock mode (it reserves its strip while visible, so it never
# covers window content). We hide/show it with SIGUSR1 based on cursor position:
#   - cursor touches the very top edge  -> show  (windows reflow down)
#   - cursor moves below the bar        -> hide  (windows reclaim the space)

reveal_zone=3      # px from the top that triggers a reveal
hide_below=46      # px; once the cursor is below this and the bar is shown, hide
poll=0.15          # seconds between checks

# make sure only one watcher runs
pidfile="${XDG_RUNTIME_DIR:-/tmp}/waybar-autohide.pid"
[ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
echo $$ > "$pidfile"

# wait for waybar, then start hidden
for _ in $(seq 1 20); do pgrep -x waybar >/dev/null && break; sleep 0.2; done
pkill -SIGUSR1 -x waybar 2>/dev/null
shown=0

while true; do
    y=$(hyprctl cursorpos -j 2>/dev/null | grep -o '"y": *[0-9-]*' | grep -o '[0-9-]*$')
    if [ -n "$y" ]; then
        if [ "$shown" -eq 0 ] && [ "$y" -le "$reveal_zone" ]; then
            pkill -SIGUSR1 -x waybar 2>/dev/null; shown=1
        elif [ "$shown" -eq 1 ] && [ "$y" -gt "$hide_below" ]; then
            pkill -SIGUSR1 -x waybar 2>/dev/null; shown=0
        fi
    fi
    sleep "$poll"
done
