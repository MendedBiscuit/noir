#!/usr/bin/env bash
# Noir screen recorder — wf-recorder → mp4 in ~/pictures/videos (mirrors the
# screenshots-in-~/pictures/screenshots convention).
#
# it's a toggle: the first call starts, the next call (or `stop`) sends SIGINT so
# wf-recorder finalizes the mp4 cleanly (moov atom written). records the focused
# output by default, or a slurp-selected region with `region`. video only, no
# audio — add --audio to the wf-recorder line if you want sound.
set -u

VIDDIR="$HOME/pictures/videos"
STATE="${XDG_RUNTIME_DIR:-/tmp}/noir-screenrec"   # holds the wf-recorder pid
FILEREF="$STATE.file"                             # holds the current output path
mkdir -p "$VIDDIR"

recording() { [ -f "$STATE" ] && kill -0 "$(cat "$STATE" 2>/dev/null)" 2>/dev/null; }

# the active output, preferring the focused one (docked -> DP-2, not the dead eDP-1)
focused_output() {
    swaymsg -t get_outputs -r 2>/dev/null \
        | jq -r 'map(select(.active)) | (map(select(.focused)) + .)[0].name // empty'
}

start() {
    local mode="$1" f args=()
    f="$VIDDIR/$(date +%Y%m%d_%H%M%S).mp4"
    if [ "$mode" = region ]; then
        local g; g=$(slurp 2>/dev/null) || exit 0        # slurp cancelled -> bail
        args=(-g "$g")
    else
        local o; o=$(focused_output)
        [ -n "$o" ] && args=(-o "$o")
    fi
    wf-recorder "${args[@]}" -f "$f" >/dev/null 2>&1 &
    echo "$!" > "$STATE"
    echo "$f"  > "$FILEREF"
    notify-send -e -t 2500 "󰑊  recording" "started ($mode) — run again to stop"
}

stop() {
    recording || { notify-send -e -t 1500 "󰑊  recording" "nothing recording"; return; }
    local pid f; pid=$(cat "$STATE"); f=$(cat "$FILEREF" 2>/dev/null)
    kill -INT "$pid" 2>/dev/null
    for _ in $(seq 1 15); do kill -0 "$pid" 2>/dev/null || break; sleep 0.2; done
    rm -f "$STATE" "$FILEREF"
    notify-send -e -t 3000 "󰑊  recording" "saved${f:+ $(basename "$f")}"
}

case "${1:-toggle}" in
    active)         recording ;;                        # exit status only (for the menu)
    status)         recording && echo "󰑊 REC" || true ;; # for a waybar module, if wanted
    stop)           stop ;;
    region)         recording && stop || start region ;;
    screen|toggle)  recording && stop || start screen ;;
    *) echo "usage: screenrec.sh [screen|region|stop|toggle|status|active]" >&2; exit 2 ;;
esac
