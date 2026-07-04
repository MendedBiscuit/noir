#!/usr/bin/env bash
# work engine — wofi project cockpit: git · dvc · claude · mcp.
# Scans ~/Data (and the home dotfiles repo) for projects, then offers
# per-project actions. Everything opens in floating glass terminals.

set -u

ROOTS=("$HOME/Data")
WOFI="wofi --dmenu --cache-file /dev/null"
CLAUDE="$HOME/.local/bin/claude"
command -v claude >/dev/null 2>&1 && CLAUDE=$(command -v claude)

# run a command in a floating terminal that stays open afterwards
hold_term() { # $1 = title, rest = bash command string
    local title="$1"; shift
    alacritty --class float-tui --title "$title" -e bash -c \
        "$*; printf '\n\033[90m── done · any key to close ──\033[0m'; read -rsn1" &
    disown
}

notify() { notify-send -e -t 4000 "$1" "${2:-}"; }

# dvc binary: project venv first, then global
dvc_bin() { # $1 = project dir
    if [ -x "$1/.venv/bin/dvc" ]; then echo "$1/.venv/bin/dvc"
    elif command -v dvc >/dev/null 2>&1; then echo "dvc"
    else echo ""; fi
}

list_ssh_hosts() {
    [ -f "$HOME/.ssh/config" ] || return 0
    awk '/^[Hh]ost /{for(i=2;i<=NF;i++) if($i !~ /[*?]/) print $i}' "$HOME/.ssh/config"
}

list_projects() {
    {
        echo "$HOME"
        find "${ROOTS[@]}" -maxdepth 4 \
            \( -name .git -o -name dvc.yaml -o -name .dvc -o -name pyproject.toml -o -name package.json \) \
            2>/dev/null | sed -E 's|/[^/]+$||'
    } | sort -u
}

# ── level 1: pick a project ──────────────────────────────────

menu=$(
    {
        printf '%s\n' "󰚩  mcp servers"
        while IFS= read -r h; do
            printf '󰣀  ssh: %s\n' "$h"
        done < <(list_ssh_hosts)
        while IFS= read -r d; do
            name=$(basename "$d")
            [ "$d" = "$HOME" ] && name="dotfiles (~)"
            tags=""
            [ -d "$d/.git" ] && tags="$tags git"
            { [ -f "$d/dvc.yaml" ] || [ -d "$d/.dvc" ]; } && tags="$tags dvc"
            printf '  %s\t%s ·%s\n' "$name" "~${d#"$HOME"}" "${tags:- plain}"
        done < <(list_projects)
    } | column -t -s $'\t' | $WOFI --prompt work --width 640 --height 440
)
[ -z "${menu:-}" ] && exit 0

# ── mcp status ───────────────────────────────────────────────

if [[ "$menu" == *"mcp servers"* ]]; then
    hold_term "mcp servers" "echo '󰚩  claude mcp servers'; echo; '$CLAUDE' mcp list"
    exit 0
fi

# ── ssh remotes ──────────────────────────────────────────────

if [[ "$menu" == *"ssh: "* ]]; then
    host="${menu##*ssh: }"
    choice=$(printf '%s\n' \
        "󰨞  vs code — remote window" \
        "  ssh terminal" \
        "󱜙  claude on remote" \
        | $WOFI --prompt "ssh · $host" --width 380 --height 220)
    case "${choice:-}" in
        *"vs code"*)   code --new-window --remote "ssh-remote+$host" & disown ;;
        *"terminal"*)  alacritty -e ssh "$host" & disown ;;
        *"claude"*)    alacritty --class askclaude -e ssh -t "$host" \
                           'command -v claude >/dev/null && exec claude || { echo "claude is not installed on this host"; exec $SHELL -l; }' & disown ;;
    esac
    exit 0
fi

# resolve the picked path (second column, '~' expanded)
dir=$(awk '{for(i=1;i<=NF;i++) if($i ~ /^~/){print $i; exit}}' <<< "$menu")
dir="${dir/#\~/$HOME}"
[ -d "$dir" ] || { notify "work engine" "path not found: $dir"; exit 1; }
name=$(basename "$dir")

# ── level 2: project actions ─────────────────────────────────

actions=$(printf '%s\n' \
    "󰨞  vs code  (claude in panel)" \
    "󱜙  claude code" \
    "󱜙  claude — continue last session" \
    "  terminal here" )

if [ -d "$dir/.git" ]; then
    actions+=$'\n'"  git status"
    actions+=$'\n'"󰶣  git sync  (pull --rebase, push)"
    actions+=$'\n'"󰆟  git commit  (review + message)"
else
    actions+=$'\n'"  git init here"
fi

if [ -f "$dir/dvc.yaml" ] || [ -d "$dir/.dvc" ]; then
    actions+=$'\n'"󰋊  dvc status"
    actions+=$'\n'"󰋊  dvc sync  (pull, push)"
fi
actions+=$'\n'"  open in files"

choice=$(printf '%s\n' "$actions" | $WOFI --prompt "$name" --width 460 --height 380)
[ -z "${choice:-}" ] && exit 0

case "$choice" in
    *"terminal here"*)
        alacritty --working-directory "$dir" & disown ;;
    *"vs code"*)
        code "$dir" & disown ;;
    *"claude — continue"*)
        alacritty --class askclaude --working-directory "$dir" -e "$CLAUDE" --continue & disown ;;
    *"claude code"*)
        alacritty --class askclaude --working-directory "$dir" -e "$CLAUDE" & disown ;;
    *"git init here"*)
        out=$(git -C "$dir" init 2>&1) \
            && notify "  git · $name" "$out" \
            || notify "  git init failed" "$out" ;;
    *"git status"*)
        hold_term "git · $name" "cd '$dir' && git status -sb && echo && git log --oneline -8 --decorate" ;;
    *"git sync"*)
        out=$(cd "$dir" && git pull --rebase --autostash 2>&1 && git push 2>&1)
        if [ $? -eq 0 ]; then notify "󰶣  git sync · $name" "$(tail -3 <<< "$out")"
        else notify "  git sync failed · $name" "$(tail -3 <<< "$out")"; fi ;;
    *"git commit"*)
        hold_term "commit · $name" "
            cd '$dir' || exit 1
            git status -sb; echo
            read -e -p 'commit message (empty aborts): ' msg
            if [ -n \"\$msg\" ]; then
                git add -A && git commit -m \"\$msg\" && echo && echo 'committed. push with git sync.'
            else
                echo 'aborted.'
            fi" ;;
    *"dvc status"*)
        DVC=$(dvc_bin "$dir")
        [ -z "$DVC" ] && { notify "󰋊  dvc" "dvc not found (no venv dvc, not on PATH)"; exit 1; }
        hold_term "dvc · $name" "cd '$dir' && '$DVC' status && echo && '$DVC' data status 2>/dev/null || true" ;;
    *"dvc sync"*)
        DVC=$(dvc_bin "$dir")
        [ -z "$DVC" ] && { notify "󰋊  dvc" "dvc not found (no venv dvc, not on PATH)"; exit 1; }
        hold_term "dvc sync · $name" "cd '$dir' && '$DVC' pull && '$DVC' push" ;;
    *"open in files"*)
        dolphin "$dir" & disown ;;
esac
