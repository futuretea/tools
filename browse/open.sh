#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    open.sh OPENPATH
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit
fi

OPENPATH=$1

if [ -f "${OPENPATH}" ]; then
    while read -r LINE; do
        xdg-open "$LINE" >/dev/null 2>&1
    done <"${OPENPATH}"
else
    xdg-open "${OPENPATH}" >/dev/null 2>&1
fi
