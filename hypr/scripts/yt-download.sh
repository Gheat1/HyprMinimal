#!/usr/bin/env bash
# Download a YouTube / SoundCloud (or any yt-dlp-supported) link in the highest
# available quality. Prompts for URL + format via wofi, then runs the download
# in a terminal window so you can watch progress and see where it saved.

if [ -z "$YTDL_RUN" ]; then
    # ── OUTER: gather input via wofi, then relaunch inside a terminal ──
    if ! command -v yt-dlp >/dev/null 2>&1; then
        notify-send "yt-dlp not installed" "Run: sudo pacman -S yt-dlp"
        exit 1
    fi

    clip="$(wl-paste 2>/dev/null)"
    case "$clip" in http*://*) prefill="$clip" ;; *) prefill="" ;; esac

    url=$(printf '%s' "$prefill" | wofi --dmenu -p "Paste URL (YouTube / SoundCloud)")
    [ -z "$url" ] && exit 0

    kind=$(printf '%s\n' " Video — best quality" " Audio — best quality" | wofi --dmenu -i -p "Format")
    [ -z "$kind" ] && exit 0

    exec kitty --class yt-dlp-dl -e env \
        YTDL_RUN=1 YTDL_URL="$url" YTDL_KIND="$kind" "$0"
fi

# ── INNER: runs inside the terminal, shows progress ──
url="$YTDL_URL"
kind="$YTDL_KIND"

case "$kind" in
    *Audio*)
        dir="$HOME/Music"
        mkdir -p "$dir"
        args=(-f "bestaudio/best" -x --embed-thumbnail --embed-metadata)
        ;;
    *)
        dir="$HOME/Videos"
        mkdir -p "$dir"
        args=(-f "bv*+ba/b" --merge-output-format mkv --embed-metadata)
        ;;
esac

clear
printf '\n  \033[1mDownloading\033[0m\n  %s\n\n  → saving to: \033[1m%s\033[0m\n\n' "$url" "$dir"
notify-send " Download started" "$url"

yt-dlp --no-playlist --progress \
       -P "$dir" -o "%(title)s.%(ext)s" \
       "${args[@]}" "$url"
status=$?

echo
if [ $status -eq 0 ]; then
    printf '  \033[1;32m✓ Done.\033[0m  Saved in: \033[1m%s\033[0m\n' "$dir"
    notify-send " Download complete" "Saved to $dir"
else
    printf '  \033[1;31m✗ Failed\033[0m (exit %s)\n' "$status"
    notify-send " Download failed" "$url"
fi
printf '\n  Press any key to close…'
read -rsn1
