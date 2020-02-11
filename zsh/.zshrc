export ZSH=$HOME/.oh-my-zsh
DISABLE_AUTO_UPDATE="true"
plugins=(git fzf z extract autojump zsh-autosuggestions)
plugins=(git z extract autojump)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

ZSH_THEME="ys"

setopt no_nomatch
source $ZSH/oh-my-zsh.sh

source $HOME/.myshrc
eval "$(kubectl completion zsh)"
eval "$(starship init zsh)"
