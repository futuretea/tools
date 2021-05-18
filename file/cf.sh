#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    cf.sh FILE BASE [OTHERS..]
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

FILE=$1
BASE=$2
shift 2
cat "${BASE}.${FILE}" >"${FILE}"
for OTHER in $@; do
    cat "${OTHER}.${FILE}" >>"${FILE}"
done
