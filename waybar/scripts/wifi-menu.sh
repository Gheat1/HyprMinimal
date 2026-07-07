#!/usr/bin/env bash
# NetworkManager wifi picker for waybar's network module (on-click).
# Lists nearby networks in wofi, connects on select (asks for a password only
# when the network is secured and not already saved), plus a wifi on/off toggle.
# Uses only nmcli + wofi — replaces the old nm-applet tray menu.

menu() { wofi --dmenu --insensitive --prompt "$1" --width 360 --height 420; }

# --- wifi radio off: offer to turn it on --------------------------------------
if [ "$(nmcli -t -f WIFI radio 2>/dev/null)" != "enabled" ]; then
    pick=$(printf '󰖩  Turn Wi-Fi on' | menu "Wi-Fi off")
    [ -n "$pick" ] && nmcli radio wifi on
    exit 0
fi

# --- list networks (strongest first, de-duped), mark the active one -----------
# nmcli --terse escapes ':' inside fields as '\:', so parse with that in mind.
list=$(nmcli --terse --fields IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan yes \
    | awk -F: '{
        # rejoin any SSID that contained an escaped colon
        ssid=$4; for (i=5;i<=NF;i++) ssid=ssid ":" $i; gsub(/\\/,"",ssid);
        if (ssid=="") next;
        mark=($1=="*") ? "󰄬" : " ";
        lock=($3=="" || $3=="--") ? " " : "󰌾";
        printf "%s %s  %s  (%s%%)\n", mark, lock, ssid, $2
    }' | awk '!seen[$0]++')

pick=$(printf '󰖪  Turn Wi-Fi off\n%s' "$list" | menu "Wi-Fi")
[ -z "$pick" ] && exit 0

if [ "$pick" = "󰖪  Turn Wi-Fi off" ]; then
    nmcli radio wifi off
    exit 0
fi

# --- recover the SSID from the chosen row -------------------------------------
# Row layout: "<mark> <lock>  <ssid>  (NN%)" — a fixed 5-char prefix (mark,
# space, lock, two spaces) then the SSID (may contain spaces) then the signal.
ssid=$(printf '%s' "$pick" | sed -E 's/^.{5}//; s/  \([0-9]+%\)$//')
[ -z "$ssid" ] && exit 0

notify() { command -v notify-send >/dev/null && notify-send -a "Wi-Fi" "$1" "$2"; }

# Already saved? bring it up. Otherwise connect, prompting for a key if needed.
if nmcli -t -f NAME connection show | sed 's/\\//g' | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" && notify "Connected" "$ssid" || notify "Failed" "$ssid"
    exit 0
fi

if nmcli device wifi connect "$ssid" 2>/dev/null; then
    notify "Connected" "$ssid"
    exit 0
fi

pass=$(wofi --dmenu --password --prompt "Password: $ssid" --width 360 --height 60 < /dev/null)
[ -z "$pass" ] && exit 0
if nmcli device wifi connect "$ssid" password "$pass"; then
    notify "Connected" "$ssid"
else
    notify "Failed" "$ssid — wrong password?"
fi
