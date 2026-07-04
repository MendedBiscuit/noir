#!/usr/bin/env bash
# noir local AI — qwen3-vl via ollama. Offline, free, open source.
#   local-ai.sh          agent mode: opencode — edits files, runs commands
#   local-ai.sh chat     plain chat REPL with the noir persona

set -u

MODEL="qwen3-vl:8b"

if ! command -v ollama >/dev/null 2>&1; then
    echo "ollama is not installed (sudo pacman -S ollama)"; read -rsn1; exit 1
fi

if ! systemctl is-active --quiet ollama; then
    echo "ollama service is not running:"
    echo "  sudo systemctl enable --now ollama"
    read -rsn1; exit 1
fi

if ! ollama list 2>/dev/null | grep -q "^${MODEL%%:*}"; then
    echo "no model yet — pulling $MODEL (~6.1 GB, resumes if interrupted)"
    ollama pull "$MODEL" || { echo "pull failed"; read -rsn1; exit 1; }
fi

# build/rebuild the noir persona — also when it's still based on an old model
if [ -f "$HOME/.config/ollama/noir.Modelfile" ] && ! ollama show noir 2>/dev/null | grep -qi qwen; then
    echo "building the noir persona from $MODEL ..."
    ollama create noir -f "$HOME/.config/ollama/noir.Modelfile"
fi

# agent base for opencode: 16k context (default 4096 truncates agent prompts)
if [ -f "$HOME/.config/ollama/noir-agent.Modelfile" ] && ! ollama list 2>/dev/null | grep -q "^noir-agent"; then
    echo "building noir-agent (16k ctx) ..."
    ollama create noir-agent -f "$HOME/.config/ollama/noir-agent.Modelfile"
fi

if [ "${1:-}" = "chat" ]; then
    shift
    exec ollama run noir "$@"
fi

if command -v opencode >/dev/null 2>&1; then
    exec opencode "$@"
else
    echo "opencode not installed (sudo pacman -S opencode) — falling back to chat"
    exec ollama run noir "$@"
fi
