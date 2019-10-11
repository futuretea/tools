#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  install_zsh_plugin.sh "
}

if [ $# -lt 0 ];then
    useage
    exit
fi

sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions

