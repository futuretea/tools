#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    cf.sh DIR FILE BASE [OTHERS..]
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
    exit 1
fi

DIR=$1
FILE=$2
BASE=$3
shift 3
cat "${DIR}/${BASE}.${FILE}" >"${DIR}/${FILE}"
for OTHER in $@; do
    cat "${DIR}/${OTHER}.${FILE}" >>"${DIR}/${FILE}"
done
