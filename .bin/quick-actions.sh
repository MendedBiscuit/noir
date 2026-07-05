#!/usr/bin/env bash
# Noir quick-actions menu (wofi dmenu): screenshots, wallpaper, toggles, panels.

set -u

SHOTDIR="$HOME/pictures/screenshots"

choice=$(printf '%s\n' \
    "󰹑  screenshot region → clipboard" \
    "󰹑  screenshot region → file" \
    "󰍹  screenshot screen → file" \
    "󰸉  next wallpaper" \
    "󰍹  toggle wallpaper hud" \
    "󰌵  toggle bluelight" \
    "󰂛  toggle do-not-disturb" \
    "  work engine" \
    "󰓓  steam (gamemode + egpu-aware)" \
    "󱜙  ask claude" \
    "󰚩  noir — local ai agent (offline)" \
    "󰭹  noir — local ai chat (fast)" \
    "󰠮  notes (logseq)" \
    "󰙏  capture thought → inbox" \
    "󱜙  explain clipboard (AI)" \
    "󰄨  system dashboard" \
    "󰌌  keybind cheatsheet" \
    "󰋗  noir manual" \
    "󰑓  reload bar" \
    "󰐥  power menu" \
    | wofi --dmenu --prompt actions --width 420 --height 420 --cache-file /dev/null)

case "${choice:-}" in
    *"region → clipboard"*) sleep 0.2; grim -g "$(slurp)" - | wl-copy && notify-send -e -t 2000 "󰹑  screenshot" "region copied to clipboard" ;;
    *"region → file"*)      sleep 0.2; f="$SHOTDIR/$(date +%Y%m%d_%H%M%S).png"; grim -g "$(slurp)" "$f" && notify-send -e -t 2000 "󰹑  screenshot" "saved $(basename "$f")" ;;
    *"screen → file"*)      sleep 0.2; f="$SHOTDIR/$(date +%Y%m%d_%H%M%S).png"; grim "$f" && notify-send -e -t 2000 "󰍹  screenshot" "saved $(basename "$f")" ;;
    *"next wallpaper"*)     ~/.bin/wallpaper.sh next ;;
    *"toggle wallpaper hud"*) ~/.bin/hud.sh toggle ;;
    *"bluelight"*)          ~/.bin/bluelight_mode.sh ;;
    *"do-not-disturb"*)     swaync-client -d ;;
    *"work engine"*)        ~/.bin/work.sh ;;
    *"steam"*)              ~/.bin/game.sh & disown ;;
    *"ask claude"*)         alacritty --class askclaude -e "$HOME/.local/bin/claude" & disown ;;
    *"local ai agent"*)     alacritty --class askclaude -e ~/.bin/local-ai.sh & disown ;;
    *"local ai chat"*)      alacritty --class askclaude -e ~/.bin/local-ai.sh chat & disown ;;
    *"notes"*)              ~/.bin/notes.sh & disown ;;
    *"capture thought"*)    ~/.bin/capture.sh & disown ;;
    *"explain clipboard"*)  alacritty --class float-tui --title "claude · clipboard" -e bash -c \
                                "wl-paste | \"$HOME/.local/bin/claude\" -p 'Explain this concisely:' ; printf '\n\033[90m── done · any key ──\033[0m'; read -rsn1" & disown ;;
    *"system dashboard"*)   ~/.bin/sysdash.sh ;;
    *"cheatsheet"*)         ~/.bin/cheatsheet.sh ;;
    *"noir manual"*)        ~/.bin/noir-manual.sh ;;
    *"reload bar"*)         pkill waybar; waybar & disown ;;
    *"power menu"*)         ~/.bin/power-menu.sh ;;
esac
