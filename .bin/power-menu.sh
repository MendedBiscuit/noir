#!/usr/bin/env bash
# Noir power menu (wofi dmenu).

set -u

choice=$(printf '%s\n' \
    "  lock — go dark" \
    "󰤄  suspend — take five" \
    "󰍃  logout — walk away" \
    "󰜉  reboot — start over" \
    "󰐥  poweroff — the big sleep" \
    | wofi --dmenu --prompt "how does it end?" --width 340 --height 250 --cache-file /dev/null \
    | awk '{print $2}')

case "${choice:-}" in
    lock)     swaylock -f ;;
    suspend)  systemctl suspend ;;
    logout)   swaymsg exit ;;
    reboot)   systemctl reboot ;;
    poweroff) systemctl poweroff ;;
esac
