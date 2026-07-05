#!/usr/bin/env bash
# Wallpaper via sway's native background — no daemon, survives reload/suspend.
#   wallpaper.sh restore   re-apply the current wallpaper (run on every reload)
#   wallpaper.sh next      cycle to the next wallpaper
# (reset is kept as an alias of restore for old callers)

set -u

DIR="$HOME/.config/sway/assets"
STATE="${XDG_RUNTIME_DIR:-/tmp}/noir-wallpaper"
DEFAULT="$DIR/3.jpg"

current() {
    [ -f "$STATE" ] && cat "$STATE" || echo "$DEFAULT"
}

apply() {
    # the hud composites the brief onto the wall and applies it itself
    if [ -x "$HOME/.bin/hud.sh" ] && "$HOME/.bin/hud.sh" enabled; then
        "$HOME/.bin/hud.sh" render
    else
        swaymsg "output * bg '$1' fill" >/dev/null
    fi
}

# wallpaper candidates (lock-screen blur excluded)
mapfile -t WALLS < <(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) ! -iname '*blur*' | sort)

case "${1:-restore}" in
    restore|reset)
        apply "$(current)"
        ;;
    next)
        cur=$(current)
        next="${WALLS[0]}"
        for i in "${!WALLS[@]}"; do
            if [ "${WALLS[$i]}" = "$cur" ]; then
                next="${WALLS[$(( (i + 1) % ${#WALLS[@]} ))]}"
                break
            fi
        done
        echo "$next" > "$STATE"   # before apply — the hud reads the state file
        apply "$next"
        ;;
    *)
        echo "usage: wallpaper.sh restore|next" >&2
        exit 1
        ;;
esac
