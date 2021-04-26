save_source(){
    [ -f $1 ] && source $1
}

save_eval(){
    [ type $1 2>/dev/null ] && eval $2
}

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/go
export GOPRIVATE=gitlab.com,gitee.com,bosun.org
export GOPROXYURL="https://goproxy.cn"
export HTTPRPOXYURL="http://host.docker.internal:12333"

export RSYNC_RSH="ssh -T -c aes128-ctr -o Compression=no -x"

export PATH=$PATH:$GOROOT/bin:$GOBIN
export PATH=$PATH:$HOME/.krew/bin
export PATH=$PATH:/usr/local/bin/tools
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin

# export GEM_HOME=$HOME/.vagrant.d/gems
# export GEM_PATH=$GEM_HOME:/opt/vagrant/embedded/gems
# export PATH=$PATH:/opt/vagrant/embedded/bin

export EDITOR='vim'
alias sudo='sudo env PATH=$PATH'
umask 022

save_source /usr/local/bin/alias/all
save_source /usr/local/bin/private/all
save_source /usr/share/nvm/nvm.sh
