#!/bin/sh
# noir-resume.sh — swayidle after-resume hook.
#
# the LG WQHD (DP-2) tunnels over USB4/Thunderbolt and comes back a moment after
# wake from s2idle; wait for it to re-enumerate, then reload sway so
# config.d/outputs re-applies cleanly — modes, positions, and the closed-lid
# state via the 'bindswitch --reload' rules. this is what fixes the external
# monitor "dying" on resume. see journal 2026-07-07.
#
# reload's only exec_always side effects are the waybar restart (wanted on wake)
# and two sudo-tee lines that harmlessly fail from an exec context.

export SWAYSOCK="${SWAYSOCK:-$(ls /run/user/"$(id -u)"/sway-ipc.* 2>/dev/null | head -1)}"

swaymsg "output * dpms on" >/dev/null 2>&1

# wait up to ~6s for the external panel to reappear over the TB link
i=0
while [ "$i" -lt 12 ]; do
    swaymsg -t get_outputs -r 2>/dev/null | grep -q '"name": *"DP-2"' && break
    i=$((i + 1))
    sleep 0.5
done

swaymsg reload >/dev/null 2>&1
