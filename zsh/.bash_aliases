save_source(){
        [ -f $1 ] && source $1
}
save_eval(){
        [ type $1 2>/dev/null ] && eval $2
}
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/bin/go
export GOPRIVATE=gitlab.com,gitee.com,bosun.org
export GOPROXYURL="https://goproxy.cn"
export HTTPRPOXYURL="http://127.0.0.1:12333"

export PATH=$PATH:$GOROOT/bin:$GOBIN
export PATH=$PATH:$HOME/.krew/bin
export PATH=$PATH:/usr/local/bin/tools
export PATH=$PATH:$HOME/.gem/ruby/2.6.0/bin

export EDITOR='vim'
alias sudo='sudo env PATH=$PATH'
umask 022
save_source /usr/local/bin/alias/all
save_source /usr/local/bin/private/all
save_source /usr/share/nvm/nvm.sh

