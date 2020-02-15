if [ -d $HOME/.oh-my-zsh ];then
    export ZSH=$HOME/.oh-my-zsh
else
    export ZSH=/usr/share/oh-my-zsh
fi
DISABLE_AUTO_UPDATE="true"
plugins=(git fzf z extract autojump zsh-autosuggestions)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

ZSH_THEME="ys"

setopt no_nomatch
source $HOME/.bash_aliases
save_source $ZSH/oh-my-zsh.sh

eval "$(kubectl completion zsh)"
eval "$(starship init zsh)"
