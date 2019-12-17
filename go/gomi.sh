#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    gomi.sh MODNAME [GOVERSION]
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit 1
fi

MODNAME=$1
GOVERSIONNOW="$(go version | awk '{print $3}' | sed 's/go//g')"
GOVERSIONNOWUSEMOD=${2-$(echo "${GOVERSIONNOW}" | awk -F "." '{print $1"."$2}')}
if [ -f go.mod ]; then
    exit_err "already a go.mod exist!"
fi

cat >go.mod <<EOF
module ${MODNAME}

go ${GOVERSIONNOWUSEMOD}
EOF
go mod tidy
