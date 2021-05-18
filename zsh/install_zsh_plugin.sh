#!/bin/bash
set -e

usage() {
    echo "usage:"
    echo "  install_zsh_plugin.sh "
}

if [ $# -lt 0 ]; then
    usage
    exit
fi

INSTALLPATH="$ZSH/custom/plugins/zsh-autosuggestions"
if [ -d "${INSTALLPATH}" ]; then
    exit
fi

git clone https://github.com/zsh-users/zsh-autosuggestions.git ${INSTALLPATH}
