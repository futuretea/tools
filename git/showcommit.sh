#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    showcommit.sh FZFINFO
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

FZFINFO=$1
COMMITID=$(echo "${FZFINFO}" | awk '{print $1}')
SHOWOPTION="--date=format:'%Y-%m-%d %H:%M:%S'"
git show "${COMMITID}" "${SHOWOPTION}"
