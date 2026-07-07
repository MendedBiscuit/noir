
# pipes.sh -p 3 -t 1 -c 8 -R 99999 -f 0.01
# echo ""

# printf '\n%.0s' {1..$(tput lines)}
# sleep 0.1
# clear

# cbonsai -l

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias work='sudo ~/.bin/focus_mode.sh work'
alias night='~/.bin/bluelight_mode.sh'
alias ai='~/.bin/local-ai.sh'

export PATH="$HOME/.local/bin:$PATH"

# DLH claude telemetry, scoped by directory.
# only export the OTLP vars while working under ~/Data/DLH, so DLH work reports
# to their Grafana and personal/vault work never does. secret stays untracked
# in ~/.config/noir/otel.env — this hook carries none of it.
_noir_otel_vars=(
  CLAUDE_CODE_ENABLE_TELEMETRY OTEL_METRICS_EXPORTER OTEL_LOGS_EXPORTER
  OTEL_EXPORTER_OTLP_PROTOCOL OTEL_EXPORTER_OTLP_ENDPOINT
  OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE OTEL_METRIC_EXPORT_INTERVAL
  OTEL_LOGS_EXPORT_INTERVAL OTEL_EXPORTER_OTLP_HEADERS
)
_noir_otel_sync() {
  if [[ "$PWD" == "$HOME/Data/DLH" || "$PWD" == "$HOME/Data/DLH/"* ]] \
     && [[ -r "$HOME/.config/noir/otel.env" ]]; then
    source "$HOME/.config/noir/otel.env"
  else
    unset $_noir_otel_vars
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _noir_otel_sync
_noir_otel_sync   # evaluate for the shell's starting directory
