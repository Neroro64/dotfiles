# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

export MODULAR_HOME="/home/nuoc/.modular"
export PATH="/home/nuoc/.modular/pkg/packages.modular.com_nightly_mojo/bin:$PATH"
export PATH=":/home/nuoc/.modular/pkg/packages.modular.com_max/bin:$PATH"
export LD_LIBRARY_PATH="/home/nuoc/.local/lib/mojo:$LD_LIBRARY_PATH"
export MAX_PATH="/home/nuoc/.modular/pkg/packages.modular.com_max"

export PATH="/root/.local/bin:$PATH"
export PATH="/home/nuoc/.local/bin:$PATH"
export PATH="/home/nuoc/.bun/bin:$PATH"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lg='lazygit'
alias rng='ranger'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
