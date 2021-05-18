#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    usef.sh FILE 
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi
FILE=${1:-$(fzf)}
BRANCH=$(git branch -l -vv | fzf | awk '{print $1}')
if [ x"${BRANCH}" != "x*" ];then
    if [ -n "${FILE}" ];then
        git checkout "${BRANCH}" -- "${FILE}"
    fi
fi
