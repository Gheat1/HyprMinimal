#!/usr/bin/env bash
# HyprMinimal installer — copies configs into place.
# Existing files with the same name are overwritten; back up first if unsure.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

echo ":: Installing HyprMinimal into $CONF"

mkdir -p "$CONF"/{hypr/scripts,hypr/shaders,waybar/scripts,wofi,mako,wlogout,Code/User,gtk-3.0,gtk-4.0,xdg-desktop-portal,systemd/user,swayosd,kitty} \
         "$HOME/.local/share/color-schemes" "$HOME/.local/share/wallpapers/minimal"

# Hyprland
cp "$DIR"/hypr/*.conf "$DIR"/hypr/hyprland.lua "$CONF/hypr/"
cp "$DIR"/hypr/scripts/*.sh "$CONF/hypr/scripts/"
cp "$DIR"/hypr/shaders/*.glsl "$CONF/hypr/shaders/"

# Wallpapers — generated locally (deterministic output, ~28 MB not kept in git).
# hyprland.lua autostarts scripts/wallpaper-cycle.sh: 5-min rotation, Super+W skips.
if python3 -c 'import PIL, numpy' 2>/dev/null; then
    echo ":: Generating minimalist wallpapers into ~/.local/share/wallpapers/minimal"
    python3 "$DIR"/wallpapers/gen-wallpapers.py >/dev/null
    cp "$DIR"/wallpapers/gen-wallpapers.py "$HOME/.local/share/wallpapers/minimal/"
else
    echo ":: SKIPPED wallpaper generation — install python-pillow and python-numpy, then run:"
    echo ":: python3 wallpapers/gen-wallpapers.py"
fi

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

# Obsidian (Monochrome theme) — installed into every registered vault.
# Vault paths are read from Obsidian's vault registry (obsidian.json); the
# theme is copied into <vault>/.obsidian/themes/Monochrome and selected as the
# active theme, preserving any other appearance.json settings.
OBS_JSON="$CONF/obsidian/obsidian.json"
if [ -f "$OBS_JSON" ] && command -v python3 >/dev/null; then
    python3 - "$OBS_JSON" "$DIR/obsidian/Monochrome" <<'PY'
import json, os, shutil, sys
reg, src = sys.argv[1], sys.argv[2]
try:
    vaults = json.load(open(reg)).get("vaults", {})
except Exception:
    vaults = {}
for v in vaults.values():
    path = v.get("path")
    if not path or not os.path.isdir(path):
        continue
    dst = os.path.join(path, ".obsidian", "themes", "Monochrome")
    os.makedirs(dst, exist_ok=True)
    for f in ("manifest.json", "theme.css"):
        shutil.copy(os.path.join(src, f), dst)
    ap = os.path.join(path, ".obsidian", "appearance.json")
    try:
        data = json.load(open(ap)) if os.path.isfile(ap) else {}
    except Exception:
        data = {}
    data["cssTheme"] = "Monochrome"
    data.setdefault("accentColor", "#8c8c8c")
    json.dump(data, open(ap, "w"), indent=2)
    print("   themed vault:", path)
PY
    echo ":: Obsidian: Monochrome theme installed (restart Obsidian to apply)."
else
    echo ":: Obsidian: no vault registry found — skipping (open Obsidian once, then re-run, or copy obsidian/Monochrome into <vault>/.obsidian/themes/ manually)."
fi

chmod +x "$CONF"/hypr/scripts/*.sh "$CONF"/waybar/scripts/*.sh

# Apply dark + monochrome toolkit settings (best-effort)
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'   || true
    gsettings set org.gnome.desktop.interface icon-theme 'YAMIS'         || true
fi
command -v plasma-apply-colorscheme >/dev/null && plasma-apply-colorscheme Monochrome || true

echo ":: Done. Install the packages (see packages.txt), then log out/in."
