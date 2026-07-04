#!/usr/bin/env bash
# Floating system dashboard — btop in a centered glass terminal.
# (window rule for app_id "sysdash" lives in the sway config)

exec alacritty --class sysdash \
    -o window.opacity=0.92 \
    -o font.size=10 \
    -e btop
