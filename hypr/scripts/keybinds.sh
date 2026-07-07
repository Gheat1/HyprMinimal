#!/usr/bin/env bash
# Keybind cheatsheet — shown in a floating terminal from the Tools menu (or Super+/).

cat <<'EOF'

   HYPRLAND KEYBINDS                          Super = Windows key

   APPS & SESSION
   Super + Return         Terminal (kitty)
   Super + R              App launcher (wofi)
   Super + E              File manager (dolphin)
   Super + T              Tools menu
   Super + /              This keybinds help
   Super + G              G-Helper (ASUS control)
   Super + L              Lock screen
   Super + Escape         Power menu
   Super + Q              Close window
   Super + Shift + Q      Exit Hyprland

   WINDOW MANAGEMENT
   Super + V              Toggle floating
   Super + F              Fullscreen
   Super + J              Toggle split direction
   Super + C              Center window
   Super + Arrows         Move focus
   Super + Shift + Arrows Move window
   Super + LMB drag       Move window
   Super + RMB drag       Resize window

   WORKSPACES
   Super + 1..0           Switch to workspace
   Super + Shift + 1..0   Move window to workspace
   Super + `              Workspace overview (expo)
   Super + S              Scratchpad (toggle)
   Super + minus          Move window to scratchpad
   Super + scroll         Cycle workspaces
   Super + Ctrl + L/R     Cycle workspaces  (= MX Master thumb hold + move)
   MX thumb tap           Workspace overview (expo)

   CAPTURE & CLIPBOARD
   Screenshot key         Region -> ~/Pictures + clipboard  (= Super+Shift+S)
   Print                  Screenshot region -> clipboard
   Shift + Print          Screenshot full -> clipboard
   Super + Print          Screenshot region -> ~/Pictures
   Super + Shift + V      Clipboard history
   Super + Shift + C      Colour picker
   Super + Shift + R      Screen record region (toggle)

   WALLPAPER
   Super + W              Next wallpaper (auto-cycles every 5 min)

   OLED CARE
   Super + Shift + O      Pixel-refresh wash

   MEDIA & HARDWARE KEYS
   Volume / Brightness    Multimedia keys
   Play / Pause / Next / Prev   Media keys
   Super + P / , / .      Play-pause / previous / next

   Press any key to close
EOF
read -rsn1
