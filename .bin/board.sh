#!/usr/bin/env bash
# noir board — the wallpaper brief, lifted off the wall and made interactive.
#
# same data as the HUD (key dates · tasks · agenda), but here you can act on it:
# tick a task done, add a task, add a key date, or drop a thought in the inbox.
# on quit it re-renders the wallpaper HUD, so your changes settle back into the
# background and the panel "disappears into the wall" again.
#
#   board.sh            open the interactive board (default)
#   board.sh preview    render the panel once and exit (no menu; for testing)
#
# launched floating + translucent by sway — Super+P, or the quick-actions menu.

set -u
export LC_ALL=C

AMBER=$'\033[1;38;2;232;160;50m'
FG=$'\033[38;2;216;216;216m'
DIM=$'\033[38;2;110;110;110m'
GOOD=$'\033[38;2;138;168;114m'
OFF=$'\033[0m'
AMBER_HEX="#e8a032"; DIM_HEX="#6e6e6e"; GOOD_HEX="#8aa872"

command -v gum >/dev/null 2>&1 || {
    printf '%s\n' "board needs 'gum' (charmbracelet/gum) — install it and retry."
    sleep 3; exit 1
}

# data layer: KEY_DATES + next_key_dates / carried_todos / inbox_count /
# load_key_dates / seed_dates_conf, plus VAULT/JOURNALS/INBOX/TODAY_FILE/DATES_CONF
# shellcheck source=/dev/null
source "$HOME/.bin/brief.sh"

# ---- panel ------------------------------------------------------------------

rule() { printf '%s── %s %s%s\n' "$DIM" "$1" "$(printf '─%.0s' $(seq 1 $((26 - ${#1}))))" "$OFF"; }

panel() {
    local buf n agenda
    buf="$(
        printf '\n%s  %s%s\n\n' "$AMBER" "$(date +'%A %-d %B')" "$OFF"

        rule "important dates"
        next_key_dates 6 | while IFS= read -r l; do
            printf '   %s%s%s\n' "$FG" "$l" "$OFF"
        done
        printf '\n'

        rule "tasks"
        local todos; todos="$(carried_todos)"
        if [ -n "$todos" ]; then
            printf '%s\n' "$todos" | head -7 | while IFS= read -r t; do
                printf '   %s☐  %s%s\n' "$FG" "$t" "$OFF"
            done
        else
            printf '   %s·  no open tasks%s\n' "$DIM" "$OFF"
        fi
        n="$(inbox_count)"
        [ "${n:-0}" -gt 0 ] && printf '   %s󰏫  %s in the inbox — type compile into Super+T%s\n' "$DIM" "$n" "$OFF"
        printf '\n'

        agenda="$(~/.bin/agenda.sh 3 2>/dev/null | head -4 | awk -F'\t' 'NF>=4{printf "%s  %s\n",$2,$4}' | cut -c1-52)"
        if [ -n "$agenda" ]; then
            rule "agenda"
            printf '%s\n' "$agenda" | while IFS= read -r a; do
                printf '   %s%s%s\n' "$FG" "$a" "$OFF"
            done
        fi
    )"
    gum style --border rounded --border-foreground "$DIM_HEX" \
        --width 66 --padding "0 3" --margin "1 2" "$buf"
}

# ---- actions ----------------------------------------------------------------

tick_task() {
    local todos sel changed=0 f
    todos="$(carried_todos)"
    [ -z "$todos" ] && { gum style --foreground "$DIM_HEX" "  nothing open to tick."; sleep 1; return; }
    sel="$(printf '%s\n' "$todos" | gum choose \
        --header "tick which task done?" --header.foreground "$DIM_HEX" \
        --cursor "❯ " --cursor.foreground "$AMBER_HEX")" || return
    [ -z "$sel" ] && return
    # flip TODO -> DONE on every journal line carrying this task (literal match)
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        awk -v t="$sel" '{ if (index($0, "TODO " t)) sub(/TODO /, "DONE "); print }' \
            "$f" > "$f.board.tmp" && mv "$f.board.tmp" "$f" && changed=1
    done < <(grep -rlF -- "TODO $sel" "$JOURNALS" 2>/dev/null)
    if [ "$changed" = 1 ]; then
        gum style --foreground "$GOOD_HEX" "  ✓ done — $sel"
    else
        gum style --foreground "$DIM_HEX" "  couldn't find that task's source line; left it as-is."
    fi
    sleep 0.8
}

add_task() {
    local t
    t="$(gum input --prompt "☐  " --placeholder "a task for today…" --width 62)" || return
    [ -z "${t// /}" ] && return
    [ -f "$TODAY_FILE" ] || : > "$TODAY_FILE"
    printf -- '- TODO %s\n' "$t" >> "$TODAY_FILE"
    gum style --foreground "$GOOD_HEX" "  + $t"
    sleep 0.6
}

add_date() {
    local d label
    d="$(gum input --prompt "󰃭  date   " --placeholder "YYYY-MM-DD (or 'next fri', 'aug 20')" --width 52)" || return
    [ -z "${d// /}" ] && return
    d="$(date -d "$d" +%F 2>/dev/null)" || { gum style --foreground "$DIM_HEX" "  not a date i understand."; sleep 1; return; }
    label="$(gum input --prompt "   label  " --placeholder "what happens?" --width 52)" || return
    [ -z "${label// /}" ] && return
    seed_dates_conf
    printf '%s|%s\n' "$d" "$label" >> "$DATES_CONF"
    load_key_dates
    gum style --foreground "$GOOD_HEX" "  󰃰 $d — $label"
    sleep 0.8
}

capture_thought() {
    local t
    t="$(gum input --prompt "󰏫  " --placeholder "a thought for the inbox…" --width 62)" || return
    [ -z "${t// /}" ] && return
    printf -- '- [[%s]] %s\n' "$(date +%F)" "$t" >> "$INBOX"
    gum style --foreground "$GOOD_HEX" "  captured."
    sleep 0.6
}

# ---- main -------------------------------------------------------------------

if [ "${1:-}" = "preview" ]; then
    panel
    exit 0
fi

while :; do
    clear
    panel
    choice="$(printf '%s\n' \
        "󰄲  tick a task done" \
        "󰐕  add a task" \
        "󰃭  add a key date" \
        "󰏫  capture a thought" \
        "󰑓  refresh" \
        "󰅖  done" \
        | gum choose --header "" --cursor "❯ " \
            --cursor.foreground "$AMBER_HEX")" || break
    case "$choice" in
        *"tick a task"*)   tick_task ;;
        *"add a task"*)    add_task ;;
        *"add a key date"*) add_date ;;
        *"capture"*)       capture_thought ;;
        *"refresh"*)       : ;;
        *"done"*|"")       break ;;
    esac
done

# settle the (possibly changed) brief back onto the wallpaper
"$HOME/.bin/hud.sh" render >/dev/null 2>&1 || true
