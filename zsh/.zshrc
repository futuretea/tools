export ZSH=/usr/share/oh-my-zsh
DISABLE_AUTO_UPDATE="true"
plugins=(git z zsh-autosuggestions)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

ZSH_THEME="ys"

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/bin/go
export GOPRIVATE=*.gitlab.com,*.gitee.com
export GOPROXYURL="https://goproxy.cn"
export HTTPRPOXYURL="http://127.0.0.1:12333"

export PATH=$PATH:$GOROOT/bin:$GOBIN
export PATH=$PATH:$HOME/.krew/bin
export PATH=$PATH:/usr/local/bin/tools

export EDITOR='vim'
setopt no_nomatch
source $ZSH/oh-my-zsh.sh
source /usr/local/bin/alias/all
eval "$(kubectl completion zsh)"
eval "$(doctl completion zsh)"
eval "$(starship init zsh)"
#PROMPT='$(kube_ps1)'$PROMPT
