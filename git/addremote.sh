#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    addremote.sh NAME HOST
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

NAME=$1
HOST=$2
REMOTE=$(git remote get-url --all origin | sed "s/git@.*:/git@git.$HOST:/")
git remote add $NAME $REMOTE
