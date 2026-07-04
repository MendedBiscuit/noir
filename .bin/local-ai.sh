#!/usr/bin/env bash
# noir local assistant — GLM via ollama. Offline, free, open source.
# Runs the "noir" model (glm4 + machine-aware system prompt) as a chat REPL.

set -u

if ! command -v ollama >/dev/null 2>&1; then
    echo "ollama is not installed (sudo pacman -S ollama)"; read -rsn1; exit 1
fi

if ! systemctl is-active --quiet ollama; then
    echo "ollama service is not running:"
    echo "  sudo systemctl enable --now ollama"
    read -rsn1; exit 1
fi

# prefer the noir persona, fall back to plain glm4
model="glm4:9b"
ollama list 2>/dev/null | grep -q "^noir" && model="noir"

if ! ollama list 2>/dev/null | grep -qE "^(noir|glm4)"; then
    echo "no model yet — pulling glm4:9b (~5.5 GB, resumes if interrupted)"
    ollama pull glm4:9b || { echo "pull failed"; read -rsn1; exit 1; }
fi

# build the noir persona once glm4 is present
if ! ollama list 2>/dev/null | grep -q "^noir" && [ -f "$HOME/.config/ollama/noir.Modelfile" ]; then
    ollama create noir -f "$HOME/.config/ollama/noir.Modelfile" && model="noir"
fi

exec ollama run "$model" "$@"
