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
save_source(){
    [ -f $1 ] && source $1
}
save_eval(){
    [ type $1 2>/dev/null ] && eval $2
}
save_source $ZSH/oh-my-zsh.sh
save_source $HOME/.myshrc

eval "$(kubectl completion zsh)"
eval "$(starship init zsh)"
