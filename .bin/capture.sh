#!/usr/bin/env bash
# noir capture — one thought, zero friction, straight into the vault inbox.
# wofi dmenu with no entries returns whatever you type on enter.

set -u

VAULT="$HOME/Data/personal/notes"

text=$(wofi --dmenu --prompt "capture" --width 560 --height 80 \
    --cache-file /dev/null </dev/null) || exit 0
[ -z "${text// /}" ] && exit 0

# magic word: "compile" (optionally followed by extra instructions) sends an
# agent through the inbox instead of adding to it — sorts thoughts into their
# pages, links them, tidies up. runs detached; a notification lands when done.
if printf '%s' "$text" | grep -qiE '^compile( |$)'; then
    extra=$(printf '%s' "$text" | sed -E 's/^[Cc]ompile *//')
    log="$HOME/.cache/noir/compile.log"
    mkdir -p "$HOME/.cache/noir"
    notify-send -e -t 3000 "󰚩  compiling" "agent is sorting the inbox…"
    (
        cd "$VAULT" || exit 1
        {
            echo "=== compile $(date +%F\ %H:%M) ==="
            "$HOME/.local/bin/claude" -p --permission-mode acceptEdits \
"You are the vault librarian. Follow the contract in ~/AGENTS.md.
Compile the capture inbox at pages/inbox.md into the vault:
- move each entry to where it belongs: an existing page (link with [[page]]),
  or today's journal (journals/$(date +%Y_%m_%d).md) if it is a day-note
- clean up wording lightly, keep julian's voice, never drop information
- leave inbox.md containing only its header line '- capture here, sort later'
- if an entry completes an open TODO in a recent journal, mark that TODO DONE
- do any small obvious tidying on pages you touch (links, typos), nothing big
${extra:+- additional instruction from julian: $extra}
Reply with one terse summary line of what you did."
        } >>"$log" 2>&1
        summary=$(tail -1 "$log")
        git add -A && git diff --cached --quiet \
            || git commit -qm "compile: inbox sorted by agent"
        notify-send -e -t 6000 "󰚩  compiled" "${summary:-inbox sorted}"
    ) & disown
    exit 0
fi

printf -- '- [[%s]] %s\n' "$(date +%Y-%m-%d)" "$text" >> "$VAULT/pages/inbox.md"
notify-send -e -t 1500 "󰠮  captured" "$text"
