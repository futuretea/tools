#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    registry-grep pattern aliasname

    registry-grep head dockerhub
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

pattern=$1
aliasname=$2


fd ${pattern} /cache/${aliasname} | awk -F "/" '{print ""$9"/"$10":"$13}'
