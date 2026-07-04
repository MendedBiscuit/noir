#!/usr/bin/env bash
# Searchable sway keybind cheatsheet — parses bindsym lines (and the comment
# directly above each one) out of the sway config and shows them in wofi.

set -u

CONFIG="$HOME/.config/sway/config"

awk '
    /^[[:space:]]*#/ {
        desc = $0
        sub(/^[[:space:]]*#[[:space:]]*/, "", desc)
        next
    }
    /^[[:space:]]*bindsym/ {
        line = $0
        sub(/^[[:space:]]*bindsym[[:space:]]+/, "", line)
        key = line
        sub(/[[:space:]].*/, "", key)
        cmd = line
        sub(/^[^[:space:]]+[[:space:]]+/, "", cmd)
        gsub(/\$mod/, "Super", key)
        gsub(/question/, "?", key)
        if (desc == "") desc = cmd
        printf "%-32s %s\n", key, desc
        desc = ""
        next
    }
    { desc = "" }
' "$CONFIG" | wofi --dmenu --prompt keys --width 720 --height 560 --cache-file /dev/null > /dev/null
