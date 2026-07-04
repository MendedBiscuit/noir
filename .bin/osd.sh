#!/usr/bin/env bash
# Volume/brightness OSD — adjusts, then shows a progress-bar notification
# that replaces itself instead of stacking.

set -u

IDFILE="${XDG_RUNTIME_DIR:-/tmp}/noir-osd-id"

osd() { # $1 = text, $2 = 0-100 value
    local prev=""
    [ -f "$IDFILE" ] && prev=$(cat "$IDFILE")
    notify-send -p ${prev:+-r "$prev"} -e -t 1200 \
        -h int:value:"$2" \
        -h string:x-canonical-private-synchronous:noir-osd \
        "$1" > "$IDFILE"
}

vol_state() { # -> "PCT MUTED?"
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100), ($3=="[MUTED]" ? 1 : 0)}'
}

case "${1:-}" in
    vol-up)      wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    vol-mute)    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic-mute)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    bright-up)   brightnessctl -q set +5% ;;
    bright-down) brightnessctl -q set 5%- ;;
    *) echo "usage: osd.sh vol-up|vol-down|vol-mute|mic-mute|bright-up|bright-down" >&2; exit 1 ;;
esac

case "$1" in
    vol-*)
        read -r pct muted <<< "$(vol_state)"
        if [ "$muted" = "1" ]; then
            osd "󰝟  muted" 0
        else
            icon="󰕿"; [ "$pct" -ge 34 ] && icon="󰖀"; [ "$pct" -ge 67 ] && icon="󰕾"
            osd "$icon  ${pct}%" "$pct"
        fi
        ;;
    mic-mute)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            osd "󰍭  mic muted" 0
        else
            osd "󰍬  mic live" 100
        fi
        ;;
    bright-*)
        pct=$(brightnessctl -m | awk -F, '{gsub("%",""); print $4}')
        osd "󰃟  ${pct}%" "$pct"
        ;;
esac
