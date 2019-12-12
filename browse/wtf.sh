#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
    cat <<"EOF"
USAGE:
    wtf.sh SOMETHING
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ];then
    useage
    exit
fi

SOMETHING=$(echo "$@"|tr -d '\n'|od -An -tx1|tr ' ' %)
open "https://www.google.com/search?q=${SOMETHING}"
open "https://www.baidu.com/s?wd=${SOMETHING}"
open "https://github.com/search?q=${SOMETHING}"
open "https://stackoverflow.com/search?q=${SOMETHING}"
open "https://medium.com/search?q=${SOMETHING}"
