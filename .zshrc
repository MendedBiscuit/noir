
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
