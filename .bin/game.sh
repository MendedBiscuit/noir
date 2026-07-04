#!/usr/bin/env bash
# Launch Steam with the right GPU and gamemode.
# With the eGPU connected (2+ DRM render nodes) everything Steam starts
# runs on it via DRI_PRIME; otherwise the 780M iGPU is used directly.

set -u

gpus=$(ls /dev/dri/renderD* 2>/dev/null | wc -l)

if [ "$gpus" -ge 2 ]; then
    export DRI_PRIME=1
    notify-send -e -t 3000 "󰓓  steam" "eGPU detected — launching on DRI_PRIME=1"
else
    notify-send -e -t 3000 "󰓓  steam" "launching on integrated 780M"
fi

if command -v gamemoderun >/dev/null 2>&1; then
    exec gamemoderun steam "$@"
else
    exec steam "$@"
fi
