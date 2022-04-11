#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    tellme.sh sendkey title content
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
    exit 1
fi

sendkey=$1
title=$2
content=$3

curl --silent --output /dev/null -fk https://sctapi.ftqq.com/${sendkey}.send?title=${title}&desp=${content}
