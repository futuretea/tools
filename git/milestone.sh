#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    mile.sh REPO
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

REPO=$1
milestone=$(curl -s https://api.github.com/repos/${REPO}/milestones | jq -r .[].title | fzf)
echo ${milestone}
