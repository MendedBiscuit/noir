#!/usr/bin/env bash
# noir hud — the brief, composited straight onto the wallpaper. no window,
# no daemon: imagemagick paints a panel onto the current wall and sway's
# native background applies it. refreshed by noir-hud.timer.
#
#   hud.sh render    rebuild + apply (default)
#   hud.sh toggle    hud on/off (off = plain wallpaper)
#   hud.sh enabled   exit 0 if the hud is on

set -u

DIR="$HOME/.config/sway/assets"
STATE="${XDG_RUNTIME_DIR:-/tmp}/noir-wallpaper"
OFF_FLAG="$HOME/.config/noir/hud-off"
OUT="${XDG_RUNTIME_DIR:-/tmp}/noir-hud.png"
FONT="/usr/share/fonts/TTF/MesloLGLDZNerdFontMono-Regular.ttf"
FONT_BOLD="/usr/share/fonts/TTF/MesloLGLDZNerdFontMono-Bold.ttf"
AMBER="#e8a032"
FG="#d8d8d8"
DIM="#6e6e6e"

# systemd user services have no SWAYSOCK — find the live one
if [ -z "${SWAYSOCK:-}" ]; then
    SWAYSOCK=$(find "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" -maxdepth 1 -name 'sway-ipc.*' 2>/dev/null | head -1)
    export SWAYSOCK
fi

base() { [ -f "$STATE" ] && cat "$STATE" || echo "$DIR/3.jpg"; }

apply_plain() { swaymsg "output * bg '$(base)' fill" >/dev/null; }

render() {
    command -v magick >/dev/null || { apply_plain; return; }
    [ -n "${SWAYSOCK:-}" ] || return 1

    read -r W H < <(swaymsg -t get_outputs \
        | jq -r '.[] | select(.active) | "\(.current_mode.width) \(.current_mode.height)"' | head -1)
    [ -n "${W:-}" ] || { W=2880; H=1800; }

    local tmp; tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN

    ~/.bin/brief.sh text > "$tmp/brief" || true
    [ -s "$tmp/brief" ] || { apply_plain; return; }

    # brief sections are separated by "---": title / agenda / todos / key dates
    awk -v d="$tmp" 'BEGIN{n=0} /^---$/{n++; next} {print > (d"/s"n)}' "$tmp/brief"

    # title in amber bold, sections in grey, thin rules between
    magick -background none -fill "$AMBER" -font "$FONT_BOLD" \
        -pointsize 24 label:@"$tmp/s0" "$tmp/p0.png"
    local parts=("$tmp/p0.png")
    local i
    for i in 1 2 3; do
        [ -s "$tmp/s$i" ] || continue
        magick -size 200x2 xc:"$DIM" "$tmp/rule$i.png"
        magick -background none -fill "$FG" -font "$FONT" \
            -pointsize 17 -interline-spacing 9 label:@"$tmp/s$i" "$tmp/p$i.png"
        parts+=("$tmp/rule$i.png" "$tmp/p$i.png")
    done

    # stack left-aligned with breathing room, panel behind, wall under it all
    magick "${parts[@]}" -background none -gravity west -smush 14 \
        -bordercolor none -border 28x24 "$tmp/text.png"
    read -r TW TH < <(magick identify -format '%w %h' "$tmp/text.png")
    magick -size "${TW}x${TH}" xc:none \
        -draw "fill rgba(10,10,10,0.80) roundrectangle 0,0,$((TW-1)),$((TH-1)),18,18" \
        "$tmp/text.png" -composite "$tmp/panel.png"
    magick "$(base)" -resize "${W}x${H}^" -gravity center -extent "${W}x${H}" \
        "$tmp/panel.png" -gravity northeast -geometry +56+72 -composite \
        "$OUT.tmp.png" && mv "$OUT.tmp.png" "$OUT"

    swaymsg "output * bg '$OUT' fill" >/dev/null
}

case "${1:-render}" in
    render)
        if [ -e "$OFF_FLAG" ]; then apply_plain; else render; fi ;;
    toggle)
        mkdir -p "$(dirname "$OFF_FLAG")"
        if [ -e "$OFF_FLAG" ]; then rm -f "$OFF_FLAG"; render; notify-send -e -t 1500 "󰍹  hud" "on"
        else touch "$OFF_FLAG"; apply_plain; notify-send -e -t 1500 "󰍹  hud" "off"; fi ;;
    enabled)
        [ ! -e "$OFF_FLAG" ] ;;
    *)
        echo "usage: hud.sh render|toggle|enabled" >&2; exit 1 ;;
esac
