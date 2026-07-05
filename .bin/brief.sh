#!/usr/bin/env bash
# noir brief — "what's up" from the vault + calendars.
#
#   brief.sh text      compact brief for the wallpaper HUD (stdout)
#   brief.sh morning   seed today's journal with due dates + carried TODOs
#                      (no-op if today's journal already exists)
#
# key dates mirror pages/sem4.md (checked 2026-07-05) — the sunday sweep
# keeps them honest.

set -u
export LC_ALL=C   # english dates regardless of system locale

VAULT="$HOME/Data/personal/notes"
JOURNALS="$VAULT/journals"
INBOX="$VAULT/pages/inbox.md"
TODAY_FILE="$JOURNALS/$(date +%Y_%m_%d).md"

KEY_DATES=(
    "2026-07-27|teaching starts (sem 2)"
    "2026-08-31|census date — last drop without fees"
    "2026-09-28|mid-sem break starts"
    "2026-10-25|teaching ends → swotvac"
    "2026-11-02|exam period starts"
)

# ---- pieces -----------------------------------------------------------------

next_key_dates() {   # $1 = how many
    local today n=0
    today=$(date +%s)
    for entry in "${KEY_DATES[@]}"; do
        local d="${entry%%|*}" label="${entry#*|}" ts diff
        ts=$(date -d "$d" +%s)
        diff=$(( (ts - today) / 86400 ))
        [ "$diff" -lt 0 ] && continue
        if [ "$diff" -eq 0 ]; then printf 'today — %s\n' "$label"
        else printf 'in %dd — %s\n' "$diff" "$label"; fi
        n=$((n+1)); [ "$n" -ge "${1:-2}" ] && break
    done
}

carried_todos() {    # unfinished TODOs from the last 7 days of journals
    find "$JOURNALS" -name '*.md' -newermt '7 days ago' -print0 2>/dev/null \
        | xargs -0 grep -h -- 'TODO ' 2>/dev/null \
        | grep -v 'DONE' \
        | sed -E 's/.*TODO +//' \
        | awk '!seen[$0]++'
}

inbox_count() {
    grep -c '^\s*- ' "$INBOX" 2>/dev/null | awk '{print ($1>0) ? $1-1 : 0}'
}

# ---- commands ---------------------------------------------------------------

case "${1:-text}" in
text)
    date +'%A %-d %B'
    echo "---"
    agenda=$(~/.bin/agenda.sh 3 | head -6 | awk -F'\t' '{printf "%s  %s\n", $2, $4}' | cut -c1-58)
    if [ -n "$agenda" ]; then
        printf '%s\n' "$agenda"
    elif [ ! -f "$HOME/.config/noir/calendars.conf" ]; then
        echo "no calendar feeds — agenda.sh setup"
    else
        echo "nothing scheduled"
    fi
    echo "---"
    todos=$(carried_todos | head -5 | sed 's/^/· /' | cut -c1-58)
    [ -n "$todos" ] && printf '%s\n' "$todos" || echo "· no open TODOs"
    n=$(inbox_count)
    [ "${n:-0}" -gt 0 ] && echo "inbox: $n unsorted — type compile into Super+T"
    echo "---"
    next_key_dates 2
    ;;

morning)
    [ -f "$TODAY_FILE" ] && exit 0
    {
        echo "- ☀ **morning brief** (auto)"
        next_key_dates 3 | sed 's/^/\t- /'
        agenda_today=$(~/.bin/agenda.sh 1 | awk -F'\t' '{printf "\t- %s — %s\n", $2, $4}')
        [ -n "$agenda_today" ] && printf '%s\n' "$agenda_today"
        carried=$(carried_todos | sed 's/^/\t- TODO /')
        if [ -n "$carried" ]; then
            echo $'\t- carried from this week:'
            printf '%s\n' "$carried" | sed 's/^\t/\t\t/'
        fi
        n=$(inbox_count)
        [ "${n:-0}" -gt 0 ] && printf '\t- [[inbox]] has %s unsorted thoughts\n' "$n"
    } > "$TODAY_FILE"
    ;;

*)
    echo "usage: brief.sh text|morning" >&2; exit 1 ;;
esac
