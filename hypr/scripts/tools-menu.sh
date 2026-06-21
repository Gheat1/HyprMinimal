#!/usr/bin/env bash
# Tools launcher — a wofi menu of handy actions.
# Bound to Super+T and the Waybar wrench button.

options=(
" Download media (yt-dlp)"
" Color picker"
" Screenshot (region)"
" Screen record (toggle)"
" Clipboard history"
" OLED pixel refresh"
" Performance profile"
" Blank screen"
" Lock screen"
" Power menu"
" Help — keybinds"
)

choice=$(printf '%s\n' "${options[@]}" | wofi --dmenu -i -p "Tools")
[ -z "$choice" ] && exit 0

case "$choice" in
    *"Download media"*)     "$HOME/.config/hypr/scripts/yt-download.sh" ;;
    *"Color picker"*)       hyprpicker -a ;;
    *"Screenshot"*)         grim -g "$(slurp)" - | wl-copy ;;
    *"Screen record"*)      pkill -INT wf-recorder || wf-recorder -g "$(slurp)" -f "$HOME/Videos/rec-$(date +%s).mp4" ;;
    *"Clipboard history"*)  cliphist list | wofi --dmenu | cliphist decode | wl-copy ;;
    *"OLED pixel refresh"*) kitty --class oled-refresh --start-as=fullscreen -e "$HOME/.config/hypr/scripts/oled-refresh.sh" 30 ;;
    *"Performance profile"*) "$HOME/.config/waybar/scripts/profile.sh" next ;;
    *"Blank screen"*)       hyprctl dispatch "hl.dsp.dpms('off')" ;;
    *"Lock screen"*)        hyprlock ;;
    *"Power menu"*)         wlogout -b 5 ;;
    *"Help"*)               kitty --class keybinds-help -e "$HOME/.config/hypr/scripts/keybinds.sh" ;;
esac
