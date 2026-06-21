#!/usr/bin/env bash
# Restore the display after suspend/resume under Hyprland.
# KWin does this automatically; Hyprland needs a nudge — a bare "dpms on" isn't
# enough, the panel needs a real modeset. We re-apply the monitor (the Lua
# parser rejects `hyprctl keyword`, so use `eval`) and reload as a backstop.

sleep 0.5
hyprctl dispatch "hl.dsp.dpms('on')"
hyprctl eval 'hl.monitor({output="eDP-1", mode="2560x1600@240", position="0x0", scale=1.6})'
hyprctl reload
brightnessctl set 60% >/dev/null 2>&1
