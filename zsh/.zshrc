if [ -d $HOME/.oh-my-zsh ];then
    export ZSH=$HOME/.oh-my-zsh
else
    export ZSH=/usr/share/oh-my-zsh
fi
DISABLE_AUTO_UPDATE="true"
export HOMEBREW_NO_AUTO_UPDATE=true
plugins=(fzf z extract zsh-autosuggestions)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

ZSH_THEME="ys"

setopt no_nomatch
source $ZSH/oh-my-zsh.sh
source $HOME/.bash_aliases
source $HOME/.asdf/asdf.sh
eval "$(kubectl completion zsh)"
eval "$(helm completion zsh)"
eval "$(starship init zsh)"
