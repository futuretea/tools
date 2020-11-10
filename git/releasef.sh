#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    releasef.sh REPO
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit 1
fi

REPO=$1
curl -s https://api.github.com/repos/${REPO}/releases | jq -r .[].tag_name | fzf

