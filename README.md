<div align="center">

# HyprMinimal

**A clean, monochrome Hyprland desktop for the ASUS ROG Zephyrus G16**

*Greyscale from border to browser. No colour, no noise.*

<br>

[![Hyprland](https://img.shields.io/badge/Hyprland-0.55%2B-blue?style=flat-square&logo=linux&logoColor=white)](https://hyprland.org)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white)](https://archlinux.org)
[![Wayland](https://img.shields.io/badge/Wayland-native-orange?style=flat-square)](https://wayland.freedesktop.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Palette](https://img.shields.io/badge/Palette-Monochrome-555555?style=flat-square)](##colour-palette)

</div>

---

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Tools Menu](#tools-menu)
- [OLED Care](#oled-care)
- [Customization](#customization)
- [Project Structure](#project-structure)
- [Credits](#credits)
- [License](#license)

---

## Overview

HyprMinimal is a fully themed, opinionated Hyprland dotfile set built around a single constraint: **no colour**. Every surface — compositor borders, status bar, launcher, notifications, lock screen, power menu, file manager, VS Code — uses the same greyscale palette. The result is a desktop that stays visually quiet and lets your actual work take centre stage.

### What makes it distinctive

- **Lua config** — uses Hyprland's `hyprland.lua` API (Hyprland 0.55+) instead of the legacy `hyprland.conf` format. Variables, loops, and functions keep the config DRY and readable.
- **Frosted glass everywhere** — translucent, blurred surfaces across windows, Waybar pills, wofi, mako, swayosd, and wlogout. Highlights use a warm *stone grey* instead of pure white.
- **Generated minimalist wallpapers** — seven dark, stone-tinted wallpapers produced by a deterministic Python script (`wallpapers/gen-wallpapers.py`), rotated every 5 minutes; `Super + W` skips to the next with a toast.
- **Rounded screen corners** — a tiny GLSL screen shader (`hypr/shaders/rounded-corners.glsl`) fades the panel's far corners to black for a soft bezel look, over everything including fullscreen.
- **OLED-first** — built for the G16's 2560×1600 240 Hz OLED panel. Dedicated burn-in mitigations are baked in at every layer (see [OLED Care](#oled-care)).
- **Full-stack theming** — the monochrome palette flows through Waybar, wofi, mako, wlogout, GTK (Adwaita-dark), a custom KDE/Qt colour scheme (`Monochrome.colors`) for Dolphin and Qt apps, the YAMIS icon theme, a hand-tuned VS Code `settings.json` with monochrome syntax highlighting, and a self-contained Obsidian `Monochrome` theme.
- **ASUS ROG integration** — works alongside G-Helper (Linux), `asusctl`, and `supergfxctl` for fan/power profiles and GPU switching. A Waybar module shows the current performance profile and lets you cycle it with a click.

---

## Screenshots

> Drop screenshots into an `assets/` folder at the root of the repo and they will appear here.

| Desktop | Tools Menu |
|---------|------------|
| ![Desktop](assets/desktop.png) | ![Tools Menu](assets/tools-menu.png) |

| Lock Screen | Workspace Overview |
|-------------|-------------------|
| ![Lock Screen](assets/lockscreen.png) | ![Expo](assets/expo.png) |

---

## Requirements

| Item | Detail |
|------|--------|
| **OS** | Arch Linux (rolling) |
| **Compositor** | Hyprland 0.55 or newer (Lua config API) |
| **Tested hardware** | ASUS ROG Zephyrus G16 GU605 — 2560×1600 @ 240 Hz OLED, 1.6× HiDPI scale |
| **Other hardware** | Any Hyprland-capable machine works; adjust the monitor block in `hypr/hyprland.lua` (see [Customization](#customization)) |

> **Note:** The ASUS-specific features (performance profile module, G-Helper autostart, `asusctl`/`supergfxctl`) are gracefully skipped on non-ASUS hardware — nothing else breaks.

---

## Dependencies

All packages are listed in [`packages.txt`](packages.txt). A summary by group:

### Core (official repos — `pacman`)

| Package | Role |
|---------|------|
| `hyprland` | Compositor |
| `kitty` | Terminal emulator |
| `waybar` | Status bar |
| `wofi` | App launcher / dmenu |
| `mako` | Notification daemon |
| `hyprpaper` | Wallpaper daemon |
| `hyprlock` | Lock screen |
| `hypridle` | Idle/DPMS daemon |
| `grim` + `slurp` + `wl-clipboard` | Screenshots and clipboard |
| `cliphist` | Clipboard history manager |
| `hyprpicker` | Colour picker |
| `wf-recorder` | Screen recorder |
| `brightnessctl` | Backlight control |
| `playerctl` | Media key control |
| `pavucontrol` | Audio mixer (GTK) |
| `network-manager-applet` | Wi-Fi tray applet |
| `yt-dlp` + `ffmpeg` | Media downloader |
| `ttf-jetbrains-mono-nerd` | UI font |
| `obsidian` | Notes (themed via `obsidian/Monochrome`) |

### ASUS ROG (g14 community repo or AUR)

```
asusctl       # fan profiles, charge limit, LED control
supergfxctl   # GPU switching (iGPU / dGPU / hybrid)
```

Follow the [asus-linux.org setup guide](https://asus-linux.org/guides/arch-guide/) to add the g14 repo before installing these.

### AUR (`yay`)

```
wlogout                  # graphical power menu
visual-studio-code-bin   # Microsoft VS Code build
```

> **YAMIS** (Yet Another Monochrome Icon Set) is the icon theme used throughout. Install it from the AUR or manually, then ensure the theme name `YAMIS` is available — the installer sets it via `gsettings` automatically.

### Workspace overview plugin

```
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
```

Requires `base-devel cmake cpio` from the official repos. See the [Installation](#installation) section for the full step-by-step.

---

## Installation

> **Back up your existing `~/.config` first.** The installer overwrites files with the same name without prompting.

### 1. Clone the repo

```bash
git clone https://github.com/yourname/HyprMinimal.git
cd HyprMinimal
```

### 2. Run the installer

```bash
./install.sh
```

This copies all configs into `~/.config/` (and `~/.local/share/color-schemes/` for the KDE colour scheme), makes the shell scripts executable, and applies dark-mode settings via `gsettings` if available.

### 3. Install packages

```bash
# Core (official repos)
sudo pacman -S --needed hyprland kitty waybar wofi mako hyprpaper hyprlock hypridle \
  grim slurp wl-clipboard cliphist hyprpicker wf-recorder brightnessctl playerctl \
  pavucontrol network-manager-applet yt-dlp ffmpeg ttf-jetbrains-mono-nerd

# AUR
yay -S wlogout visual-studio-code-bin

# ASUS tools (add the g14 repo first — see asus-linux.org)
sudo pacman -S --needed asusctl supergfxctl
```

### 4. Enable system services

```bash
systemctl --user enable --now hypridle.service
sudo systemctl enable --now asusd.service       # ASUS only
sudo systemctl enable --now supergfxd.service   # ASUS only
```

### 5. Install the hyprexpo plugin

```bash
sudo pacman -S --needed base-devel cmake cpio
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
```

The config already calls `hyprpm reload -n` on startup, so the plugin loads automatically once installed.

### 6. Apply the KDE/Qt colour scheme

```bash
plasma-apply-colorscheme Monochrome
```

Or open **System Settings → Colors** and select **Monochrome** from the list.

### 7. Log out and back in

Start a Hyprland session from your display manager. Everything should come up themed.

---

## Keybindings

`Super` = the Windows key / Meta key.

### Apps & Session

| Keybind | Action |
|---------|--------|
| `Super + Return` | Open terminal (kitty) |
| `Super + R` | App launcher (wofi) |
| `Super + E` | File manager (Dolphin) |
| `Super + T` | Tools menu |
| `Super + /` | Keybinds cheatsheet (floating terminal) |
| `Super + G` | G-Helper (ASUS control panel) |
| `Super + L` | Lock screen |
| `Super + Escape` | Power menu (wlogout) |
| `Super + Q` | Close focused window |
| `Super + Shift + Q` | Exit Hyprland |

### Window Management

| Keybind | Action |
|---------|--------|
| `Super + V` | Toggle floating |
| `Super + F` | Toggle fullscreen |
| `Super + J` | Toggle split direction |
| `Super + C` | Center window |
| `Super + Arrows` | Move focus (left / right / up / down) |
| `Super + Shift + Arrows` | Move window in layout |
| `Super + LMB drag` | Move floating window |
| `Super + RMB drag` | Resize window |

### Workspaces

| Keybind | Action |
|---------|--------|
| `Super + 1..0` | Switch to workspace 1–10 |
| `Super + Shift + 1..0` | Move window to workspace 1–10 |
| `` Super + ` `` | Workspace overview (hyprexpo) |
| `Super + S` | Toggle scratchpad |
| `Super + minus` | Move window to scratchpad |
| `Super + Scroll` | Cycle workspaces |

Three-finger horizontal swipe also switches workspaces via the touchpad gesture binding.

### Capture & Clipboard

| Keybind | Action |
|---------|--------|
| `Print` | Screenshot region → clipboard |
| `Shift + Print` | Screenshot full screen → clipboard |
| `Super + Print` | Screenshot region → `~/Pictures/` |
| `Super + Shift + S` | Screenshot region → `~/Pictures/` + clipboard (laptop's snip key) |
| `Super + Shift + V` | Clipboard history picker (cliphist + wofi) |
| `Super + Shift + C` | Colour picker → clipboard (hyprpicker) |
| `Super + Shift + R` | Screen record region (toggle wf-recorder) |

### Wallpaper

| Keybind | Action |
|---------|--------|
| `Super + W` | Next wallpaper (auto-cycles every 5 minutes; shows a toast) |

### OLED Care

| Keybind | Action |
|---------|--------|
| `Super + Shift + O` | Pixel-refresh wash (30 s colour cycle) |

### Media & Hardware Keys

| Key | Action |
|-----|--------|
| Volume Up / Down / Mute | swayosd — PipeWire sink |
| Mic Mute | swayosd — PipeWire source |
| Brightness Up / Down | brightness.sh + swayosd OSD |
| Play / Pause / Next / Prev | playerctl |
| `Super + P` / `Super + ,` / `Super + .` | Play-pause / previous / next |

---

## Tools Menu

Open with `Super + T` or click the wrench icon () in Waybar. A wofi dmenu lists quick actions:

| Option | What it does |
|--------|-------------|
| **Download media (yt-dlp)** | Prompts for a URL (pre-filled from clipboard if it looks like a link) and format (Video / Audio). Runs `yt-dlp` inside a kitty terminal so you can watch live progress. Audio saves to `~/Music`; video saves to `~/Videos` as MKV at best quality. |
| **Color picker** | `hyprpicker -a` — click anywhere, hex code copied to clipboard. |
| **Screenshot (region)** | `grim` + `slurp` region select → clipboard. |
| **Screen record (toggle)** | Starts a region `wf-recorder` capture; running the action again sends `SIGINT` to stop and finalise the file in `~/Videos/`. |
| **Clipboard history** | `cliphist` list piped through wofi — select an entry to paste it. |
| **OLED pixel refresh** | Launches a borderless fullscreen kitty window and cycles solid R/G/B/white/black/grey fills for 30 seconds to exercise every sub-pixel evenly. |
| **Performance profile** | Calls `asusctl profile -n` to cycle Silent → Balanced → Performance. The Waybar module updates within 5 seconds. |
| **Blank screen** | `hyprctl dispatch dpms off` — screen wakes on any input. |
| **Lock screen** | `hyprlock`. |
| **Power menu** | `wlogout` with six buttons: Lock, Logout, Suspend, Hibernate, Reboot, Shutdown. |
| **Help — keybinds** | Opens the keybinds cheatsheet in a floating, centered kitty window (same as `Super + /`). |

---

## OLED Care

The G16's OLED panel is spectacular, but OLEDs benefit from a few precautions against uneven wear. HyprMinimal bakes these in at every layer:

### Low-luminance dark theme

The base background is `#0a0a0b` — essentially black. Inactive windows drop to 96% opacity. The lock screen desaturates and dims the blurred screenshot (`brightness = 0.55`, `vibrancy = 0.0`). Less light emitted means less cumulative wear on any one pixel region.

### Overlap-free Waybar auto-hide

`waybar/scripts/autohide.sh` runs on startup and polls the cursor Y position every 150 ms via `hyprctl cursorpos`. When the cursor reaches within 3 px of the top edge, it sends `SIGUSR1` to Waybar to **show** the bar; when the cursor moves below 46 px the bar **hides** again.

Crucially, Waybar is configured in **dock mode** (`"layer": "top"` with reserved space). This means showing/hiding the bar causes windows to reflow rather than slide under it — so the bar's strip is only ever lit when you actively use it, and no static UI element burns in above your windows.

### Blank screen hotkey

`Super + O` fires `hyprctl dispatch dpms off` immediately. The display wakes on any mouse or keyboard input. Useful when stepping away briefly.

### Pixel-refresh wash

`Super + Shift + O` (or Tools menu → OLED pixel refresh) launches `hypr/scripts/oled-refresh.sh` in a borderless, animation-free, fullscreen kitty window. The script cycles the entire display through solid black → white → red → green → blue → mid-grey at 10-frame intervals for 30 seconds, ensuring every pixel and sub-pixel runs through its full luminance range to even out wear patterns.

The window rule for `oled-refresh` sets `border_size = 0`, `rounding = 0`, and `no_anim = true` so nothing interrupts the full-screen fill.

### Idle management (hypridle)

`hypr/hypridle.conf` defines a four-stage idle sequence:

| Timeout | Action |
|---------|--------|
| 2.5 min | Dim backlight to 10% (saves on restore) |
| 5 min | Lock screen via `loginctl lock-session` |
| 5.5 min | DPMS off (`hyprctl dispatch dpms off`) |
| 20 min | System suspend |

The screen is locked **before** sleep and displays are re-enabled after resume.

---

## Customization

### Colour palette

All surfaces use a near-black base with warm **stone grey** highlights (greys pulled slightly toward beige — a little less white, a little more paper):

| Token | Hex | Used for |
|-------|-----|---------|
| Background | `#0a0a0b` | Base surface, editor, terminal |
| Surface | `rgba(6,6,7,~0.5)` | Frosted Waybar pills, mako notifications, input fields |
| Border | `#34322d` | Active window border; warm dark stone |
| Muted text | `#86817a` | Inactive labels, window title |
| Text | `#bfbab1` | Primary text everywhere |
| Accent / stone | `#c9c4b9` | Active workspace chip, clock, selections, hovers (`#d6d1c8`) |

To change the accent, replace the `#c9c4b9` / `#bfbab1` / `#d6d1c8` references in `waybar/style.css`, `wofi/style.css`, `wlogout/style.css`, `kitty/monochrome.conf`, and `kde/Monochrome.colors`, plus `active_border` in `hypr/hyprland.lua`.

### Monitor and scale

Edit the `hl.monitor()` block at the top of `hypr/hyprland.lua`:

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@240",
    position = "0x0",
    scale    = 1.6,          -- adjust for your panel DPI
})
```

Run `hyprctl monitors` to find your output name. External monitors are handled automatically by the second (catch-all) monitor block which uses `mode = "preferred"` and `scale = "auto"`.

### Font

The font is set in three places:

| File | Key |
|------|-----|
| `waybar/style.css` | `font-family: "JetBrainsMono Nerd Font"` |
| `wofi/style.css` | `font-family: "JetBrainsMono Nerd Font"` |
| `hypr/hyprlock.conf` | `font_family = JetBrainsMono Nerd Font` |

Replace the font name in all three files to switch. Any Nerd Font will keep the glyphs in Waybar and mako working.

### Performance profile cycling

`waybar/scripts/profile.sh` tries `asusctl profile -p` first, then falls back to `/sys/firmware/acpi/platform_profile`. On non-ASUS hardware the module will still work if your kernel exposes the platform profile sysfs node.

### Wallpapers

Seven dark minimalist wallpapers are generated into `~/.local/share/wallpapers/minimal/` by `wallpapers/gen-wallpapers.py` (deterministic — same output every run; needs `python-pillow` + `python-numpy`). `hypr/scripts/wallpaper-cycle.sh` rotates through them every 5 minutes and `Super + W` skips ahead immediately.

To tweak the designs, edit the generator (each wallpaper is a few lines of numpy) and re-run it. To use your own images, drop PNGs into the same folder — the cycler picks up everything matching `*.png`.

Two hyprpaper 0.8 gotchas baked into the setup, should you rework it:

- The IPC request needs an **explicit monitor name** — hyprpaper matches explicit states first, then the *first* wildcard, which is always the config's `monitor = *` entry, so monitor-less requests are silently ignored.
- Use `monitor = *` rather than an empty `monitor =` in `hyprpaper.conf` — hyprlang drops special-category entries keyed by an empty string.

### Rounded screen corners

`hypr/shaders/rounded-corners.glsl` is applied as `decoration:screen_shader` — it fades the framebuffer to black outside a rounded rect on every monitor. Adjust `radius = 24.0` (physical pixels) and `hyprctl reload`. Note that screenshots are unaffected by design: Hyprland hands screen-capture tools the pre-shader frame.

---

## Project Structure

```
HyprMinimal/
├── hypr/
│   ├── hyprland.lua          # Main Hyprland config (Lua API, Hyprland 0.55+)
│   ├── hyprlock.conf         # Lock screen: blurred greyscale screenshot + clock
│   ├── hypridle.conf         # Idle → dim → lock → DPMS off → suspend pipeline
│   ├── hyprpaper.conf        # Wallpaper daemon config (static base; script cycles via IPC)
│   ├── shaders/
│   │   └── rounded-corners.glsl  # Screen shader: soft black bezel corners
│   └── scripts/
│       ├── tools-menu.sh     # Wrench/Super+T launcher — wofi dmenu of actions
│       ├── yt-download.sh    # yt-dlp wrapper: clipboard prefill, in-terminal progress
│       ├── oled-refresh.sh   # Full-screen R/G/B/white/black wash for OLED care
│       ├── wallpaper-cycle.sh # 5-min wallpaper rotation; SIGUSR1 (Super+W) skips
│       ├── brightness.sh     # OLED-aware backlight steps + swayosd OSD
│       ├── on-resume.sh      # Post-suspend fixups
│       └── keybinds.sh       # Cheatsheet printed in a floating terminal
├── wallpapers/
│   └── gen-wallpapers.py     # Deterministic generator: 7 dark stone-tinted minimal walls
├── waybar/
│   ├── config.jsonc          # Bar layout: tools | workspaces | title — clock — profile | brightness | audio | wifi | battery | tray
│   ├── style.css             # Frosted stone pill theme for all Waybar modules
│   └── scripts/
│       ├── autohide.sh       # Cursor-watcher: SIGUSR1 hide/show, dock-mode, no overlap
│       ├── power.sh          # Laptop + peripheral battery readout (upower/solaar/bluetoothctl)
│       ├── lowpower.sh       # Eco toggle: quiet profile, EPP, 60 Hz, blur/anim off
│       ├── wifi-menu.sh      # Wi-Fi picker
│       └── profile.sh        # ASUS performance profile: status JSON + cycle-next
├── wofi/
│   ├── config                # Launcher settings (520×420, centered, dark)
│   └── style.css             # Monochrome wofi theme
├── mako/
│   └── config                # Notification style: top-right, greyscale, 5 s timeout
├── wlogout/
│   ├── layout                # Six buttons: lock / logout / suspend / hibernate / reboot / shutdown
│   └── style.css             # Monochrome wlogout theme
├── kde/
│   └── Monochrome.colors     # KDE/Qt colour scheme for Dolphin and Qt apps
├── gtk/
│   ├── gtk-3.0-settings.ini  # GTK3: Adwaita-dark + YAMIS icons
│   └── gtk-4.0-settings.ini  # GTK4: same
├── vscode/
│   └── settings.json         # Monochrome editor theme + greyscale syntax tokens
├── packages.txt              # Full dependency list with install one-liners
├── install.sh                # Copies configs into ~/.config, sets gsettings
└── LICENSE                   # MIT
```

---

## Credits

- [Hyprland](https://hyprland.org) — the compositor and Lua config API
- [Waybar](https://github.com/Alexays/Waybar) — the status bar
- [wofi](https://hg.sr.ht/~scoopta/wofi) — the application launcher
- [mako](https://github.com/emersion/mako) — the notification daemon
- [hyprlock](https://github.com/hyprwm/hyprlock) + [hypridle](https://github.com/hyprwm/hypridle) — lock screen and idle management
- [hyprexpo](https://github.com/hyprwm/hyprland-plugins) — workspace overview plugin
- [G-Helper](https://github.com/seerge/g-helper) — lightweight ASUS ROG control (Linux)
- [asusctl](https://gitlab.com/asus-linux/asusctl) + [supergfxctl](https://gitlab.com/asus-linux/supergfxctl) — ASUS fan/power/GPU management
- [YAMIS](https://github.com/junicode/YAMIS) — Yet Another Monochrome Icon Set
- [JetBrains Mono Nerd Font](https://www.nerdfonts.com) — the UI font used everywhere
- [wf-recorder](https://github.com/ammen99/wf-recorder), [grim](https://sr.ht/~emersion/grim/), [slurp](https://github.com/emersion/slurp), [cliphist](https://github.com/sentriz/cliphist), [hyprpicker](https://github.com/hyprwm/hyprpicker), [yt-dlp](https://github.com/yt-dlp/yt-dlp) — the supporting utilities

---

## License

MIT — see [LICENSE](LICENSE).
