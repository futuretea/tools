#!/bin/bash
#set -e

usage() {
    echo "usage:"
    echo "  gcu.sh user_name user_email --local"
}

show_user() {
    git config --list --show-origin | grep user
}

if [ $# -lt 2 ]; then
    show_user
    usage
    exit
fi

NAME=$1
EMAIL=$2
shift 2
show_user
git config user.name "${NAME}" $@
git config user.email "${EMAIL}" $@
show_user
