#!/usr/bin/env bash
# noir sunday sweep — weekly agent pass over the vault: sort what the week
# left loose, link it, surface what was dropped. runs from noir-sweep.timer
# (sunday 17:00) or by hand.

set -u

VAULT="$HOME/Data/personal/notes"
LOG="$HOME/.cache/noir/sweep.log"
mkdir -p "$HOME/.cache/noir"

cd "$VAULT" || exit 1

{
    echo "=== sweep $(date +%F\ %H:%M) ==="
    "$HOME/.local/bin/claude" -p --permission-mode acceptEdits \
"You are the vault librarian doing the weekly sunday sweep. Follow the
contract in ~/AGENTS.md. Today is $(date +%F).
Pass over the last 7 days of journals/ plus pages/inbox.md:
- sort any inbox entries into their pages or journals, leave only the header
- mark TODOs DONE where a later journal shows they were completed
- collect TODOs that were dropped (mentioned once, never resolved) and list
  them in today's journal under a '- 󰃢 **sunday sweep** (auto)' block, each
  as a TODO with a [[link]] to where it came from
- fix obvious missing [[links]] between pages the week touched
- if key dates changed on [[sem4]], update the KEY_DATES table in ~/.bin/brief.sh
- keep edits small and in julian's voice; never delete content
Reply with one terse summary line."
} >>"$LOG" 2>&1

summary=$(tail -1 "$LOG")
git add -A && git diff --cached --quiet \
    || git commit -qm "sunday sweep: weekly sort + dropped-todo roundup"
notify-send -e -t 6000 "󰃢  sunday sweep" "${summary:-done}" 2>/dev/null || true
