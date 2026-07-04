#!/usr/bin/env bash
# noir manual — what this rice is, how it fits together, where everything lives.
# Spawns a floating pager; run with "page" (or from a tty) to print directly.

set -u

# Always spawn the floating pager window. Checking -t 1 here is a trap:
# sway inherits the login tty, so keybind-spawned processes think they
# have a terminal and page to the invisible tty1 instead.
if [ "${1:-}" != "page" ]; then
    exec alacritty --class noir-manual -e "$0" page
fi

W=$'\033[1;97m'   # bright white bold
G=$'\033[0;37m'   # light gray
D=$'\033[0;90m'   # dim gray
R=$'\033[0m'      # reset

swatch() { printf '\033[48;2;%sm    \033[0m' "$1"; }

{
printf '%s\n' "
${D}┌───────────────────────────────────────────────────────────────┐${R}
${D}│${R}   ${W}N O I R${R}   ${D}·  a monochrome sway rice  ·  Super+Ctrl+/${R}       ${D}│${R}
${D}└───────────────────────────────────────────────────────────────┘${R}

${W}THE THEME${R}
  Pure grayscale, black glass, 1px hairlines. There is no color
  anywhere on this system — even the terminal's 16 ANSI colors map
  to grays. Contrast, spacing, transparency and motion do the work
  that color usually does.

  palette   $(swatch "0;0;0") $(swatch "26;26;26") $(swatch "51;51;51") $(swatch "77;77;77") $(swatch "128;128;128") $(swatch "179;179;179") $(swatch "230;230;230") $(swatch "255;255;255")
            ${D}#000    #1a1a1a #333    #4d4d4d #808080 #b3b3b3 #e6e6e6 #fff${R}

  fonts     ${G}Noto Sans (UI) · Hack (terminal) · FiraCode Nerd Font (icons)${R}
  walls     ${G}grayscale sand ripples — ~/.config/sway/assets${R}

${W}ANATOMY${R}
  ${G}bar${R}        waybar — glass pills; most modules are clickable
             ${D}volume: click = mute · cpu/mem: click = dashboard${R}
             ${D}clock: click = full date, hover = calendar${R}
  ${G}launcher${R}   wofi, black glass          ${D}Super+Space${R}
  ${G}notifs${R}     swaync — control center with DND, sliders, toggles
             ${D}Super+Ctrl+N · bell icon in the bar${R}
  ${G}lock${R}       swaylock over blurred ripples
  ${G}wallpaper${R}  sway-native background — daemonless, unbreakable

${W}MENUS & KEYS${R}
  ${G}Super+Space${R}         app launcher
  ${G}Super+Escape${R}        quick actions — screenshots, toggles, panels
  ${G}Super+D${R}             work engine — projects: git · dvc · claude
  ${G}Super+C${R}             claude — cloud AI terminal
  ${G}Super+V${R}             noir — local vision agent (qwen3-vl, offline)
  ${G}Super+O${R}             notes — logseq vault (plain markdown)
  ${G}Super+I${R}             system dashboard (btop)
  ${G}Super+Slash${R}         keybind cheatsheet (parsed live from config)
  ${G}Super+Ctrl+Slash${R}    this manual
  ${G}Super+Shift+E${R}       power menu — 'the big sleep'
  ${G}Super+Shift+B${R}       next wallpaper
  ${G}Super+B${R}             bluelight filter
  ${G}Super+L${R}             lock now

${W}WORK ENGINE${R}  ${D}(Super+D)${R}
  Scans ~/Data for projects (.git, dvc.yaml, pyproject, package.json)
  plus the home dotfiles repo. Per project:
    terminal · vs code · claude code (fresh or --continue)
    git status / sync (pull --rebase + push) / commit (review + msg)
    dvc status / sync — via the project venv's dvc when present
  'mcp servers' at the top shows claude mcp list.

${W}AI${R}
  ${G}claude${R} (Super+C) for the heavy, frontier-grade agentic work — cloud.
  ${G}noir${R} (Super+V) for the everyday, fully offline: qwen3-vl:8b via
  ollama, driven by opencode — it sees images, edits files and runs
  commands (with confirmation). Free and open source.
    ${G}ai${R}          agent in the current directory
    ${G}ai chat${R}     plain chat with the noir persona
    ${G}ollama run noir 'how do i ...'${R}   headless one-shot

${W}NOTES${R}  ${D}(Super+O)${R}
  logseq — open-source obsidian. The vault is plain markdown at
  ~/Data/personal/notes: no database, no lock-in, git for sync
  (it shows up in the work engine like any repo). The local AI
  can read and edit pages directly — run ${G}ai${R} inside the vault.
  Grayscale custom.css included, obviously.

${W}GAMING${R}
  Native steam + proton-cachyos + gamemode. Launch via quick actions
  or ${G}game.sh${R} — it picks the eGPU automatically when connected.
  Useful per-game launch options (steam → properties):
    ${G}mangohud %command%${R}                       fps overlay
    ${G}gamescope -W 2880 -H 1800 -f -- %command%${R}  crisp hidpi fullscreen
  Set proton-cachyos under settings → compatibility.

${W}FILES${R}
  ${G}sway${R}       ~/.config/sway/config ${D}(+ colorscheme, config.d/)${R}
  ${G}bar${R}        ~/.config/waybar/{config,style.css}
  ${G}launcher${R}   ~/.config/wofi/{config,style.css}
  ${G}notifs${R}     ~/.config/swaync/{config.json,style.css}
  ${G}lock${R}       ~/.config/swaylock/config
  ${G}dashboard${R}  ~/.config/btop/ ${D}(noir theme)${R}
  ${G}fetch${R}      ~/.config/fastfetch/config.jsonc
  ${G}scripts${R}    ~/.bin/*.sh
  everything is tracked in the home dotfiles git repo

${W}SCRIPTS${R}  ${D}(~/.bin)${R}
  ${G}work.sh${R}          project cockpit: git · dvc · claude · mcp
  ${G}quick-actions.sh${R} screenshots, wallpaper, toggles
  ${G}power-menu.sh${R}    go dark · take five · the big sleep
  ${G}cheatsheet.sh${R}    live keybind list from the sway config
  ${G}noir-manual.sh${R}   this page
  ${G}local-ai.sh${R}      noir, the offline assistant
  ${G}notes.sh${R}         logseq on the notes vault
  ${G}game.sh${R}          steam with gamemode + egpu autodetect
  ${G}osd.sh${R}           volume/brightness pop-ups
  ${G}wallpaper.sh${R}     native sway background + cycling
  ${G}sysdash.sh${R}       floating btop
  ${G}bluelight_mode.sh${R} gammastep toggle
  ${G}focus_mode.sh${R}    hosts-file distraction blocking

  ${D}q to quit${R}
"
} | less -R
