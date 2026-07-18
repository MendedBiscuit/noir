#!/usr/bin/env bash
# Mouse sensitivity slider (zenity, live preview) -> libinput pointer_accel,
# applied immediately and persisted to config.d/inputs.

set -u

CONF="$HOME/.config/sway/config.d/inputs"

cur=$(grep -m1 -oP 'pointer_accel \K[-0-9.]+' "$CONF")
cur=${cur:-0}
start=$(awk -v a="$cur" 'BEGIN{printf "%d", (a*50)+50}')

last="$start"
while read -r slider; do
    last="$slider"
    accel=$(awk -v s="$slider" 'BEGIN{printf "%.2f", (s-50)/50}')
    swaymsg input type:pointer pointer_accel "$accel" >/dev/null
done < <(zenity --scale --title "mouse sensitivity" --text "drag to adjust — live preview" \
    --min-value=0 --max-value=100 --value="$start" --step=1 --print-partial)

accel=$(awk -v s="$last" 'BEGIN{printf "%.2f", (s-50)/50}')
sed -i "s/pointer_accel [-0-9.]\+/pointer_accel $accel/" "$CONF"
notify-send -e -t 1500 "󰍽  mouse sensitivity" "accel ${accel}"
