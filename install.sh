#!/usr/bin/env bash
# HyprMinimal installer — copies configs into place.
# Existing files with the same name are overwritten; back up first if unsure.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Installing HyprMinimal into $CONF"

mkdir -p "$CONF"/{hypr/scripts,waybar/scripts,wofi,mako,wlogout,Code/User,gtk-3.0,gtk-4.0,xdg-desktop-portal,systemd/user,swayosd,kitty} \
         "$HOME/.local/share/color-schemes"

# Hyprland
cp "$DIR"/hypr/*.conf "$DIR"/hypr/hyprland.lua "$DIR"/hypr/wallpaper.png "$CONF/hypr/"
cp "$DIR"/hypr/scripts/*.sh "$CONF/hypr/scripts/"

# Waybar
cp "$DIR"/waybar/config.jsonc "$DIR"/waybar/style.css "$CONF/waybar/"
cp "$DIR"/waybar/scripts/*.sh "$CONF/waybar/scripts/"

# swayosd (on-screen volume/brightness slider)
cp "$DIR"/swayosd/style.css "$CONF/swayosd/"

# kitty (monochrome dark-grey theme)
cp "$DIR"/kitty/kitty.conf "$DIR"/kitty/monochrome.conf "$CONF/kitty/"

# wofi / mako / wlogout
cp "$DIR"/wofi/config "$DIR"/wofi/style.css "$CONF/wofi/"
cp "$DIR"/mako/config "$CONF/mako/"
cp "$DIR"/wlogout/layout "$DIR"/wlogout/style.css "$CONF/wlogout/"

# Screensharing: portal backend routing + session target.
# Routes screencast to xdg-desktop-portal-hyprland (so the KDE portal can't grab
# and hang it), and brings up graphical-session.target on this non-UWSM session so
# the portal can start. Needs: pipewire wireplumber xdg-desktop-portal-hyprland.
cp "$DIR"/portal/portals.conf            "$CONF/xdg-desktop-portal/"
cp "$DIR"/systemd/hyprland-session.target "$CONF/systemd/user/"

# VS Code + KDE/Qt color scheme + GTK
cp "$DIR"/vscode/settings.json "$CONF/Code/User/settings.json"
cp "$DIR"/kde/Monochrome.colors "$HOME/.local/share/color-schemes/"
cp "$DIR"/gtk/gtk-3.0-settings.ini "$CONF/gtk-3.0/settings.ini"
cp "$DIR"/gtk/gtk-4.0-settings.ini "$CONF/gtk-4.0/settings.ini"
cp "$DIR"/gtk/gtk-3.0.css "$CONF/gtk-3.0/gtk.css"
cp "$DIR"/gtk/gtk-4.0.css "$CONF/gtk-4.0/gtk.css"

chmod +x "$CONF"/hypr/scripts/*.sh "$CONF"/waybar/scripts/*.sh

# Apply dark + monochrome toolkit settings (best-effort)
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'   || true
    gsettings set org.gnome.desktop.interface icon-theme 'YAMIS'         || true
fi
command -v plasma-apply-colorscheme >/dev/null && plasma-apply-colorscheme Monochrome || true

echo ":: Done. Install the packages (see packages.txt), then log out/in."
