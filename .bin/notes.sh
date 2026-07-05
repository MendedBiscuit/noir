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

# native wayland — the display runs at scale 2, xwayland would be blurry.
# GTK_THEME + --force-dark-mode: electron can't see prefer-dark through the
# portal on sway, so logseq's "system" theme resolves light without these.
export GTK_THEME=Adwaita:dark
exec logseq --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations --force-dark-mode "$@"
