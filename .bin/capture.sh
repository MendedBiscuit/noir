#!/usr/bin/env bash
# noir capture — one thought, zero friction, straight into the vault inbox.
# wofi dmenu with no entries returns whatever you type on enter.

set -u

VAULT="$HOME/Data/personal/notes"

text=$(wofi --dmenu --prompt "capture" --width 560 --height 80 \
    --cache-file /dev/null </dev/null) || exit 0
[ -z "${text// /}" ] && exit 0

printf -- '- [[%s]] %s\n' "$(date +%Y-%m-%d)" "$text" >> "$VAULT/pages/inbox.md"
notify-send -e -t 1500 "󰠮  captured" "$text"
