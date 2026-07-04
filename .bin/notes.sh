#!/usr/bin/env bash
# noir notes — logseq (open-source obsidian) on the ~/Data/personal/notes vault.
# Plain markdown on disk: the local AI can read/edit it, git syncs it for free.

set -u

if ! command -v logseq >/dev/null 2>&1; then
    exec alacritty --class float-tui -e sh -c '
        echo "logseq is not installed yet:"
        echo "  paru -S logseq-desktop-bin"
        printf "\nany key to close"; read -rsn1'
fi

# native wayland — the display runs at scale 2, xwayland would be blurry
exec logseq --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations
