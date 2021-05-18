#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    goe.sh GOMODULE PMMODE(mod,other) PROXYMODE(mod,other)
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

GOMODULE=$1
PMMODE=${2-"mod"}
PROXYMODE=${3-"mod"}
if [ x"${PMMODE}" == "xmod" ]; then
    USEGOMOD=true
else
    USEGOMOD=false
fi
if [ x"${PROXYMODE}" == "xmod" ]; then
    USEPROXY=gomod
    NOPROXY=git,sh
else
    USEPROXY=git,sh
    NOPROXY=gomod
fi
GOVERSIONNOW="$(go version | awk '{print $3}' | sed 's/go//g')"
cat >go.env <<EOF
GOMODULE=${GOMODULE}
GOVERSION=${GOVERSIONNOW}
USEGOMOD=${USEGOMOD}
USEPROXY=${USEPROXY}
NOPROXY=${NOPROXY}
EOF
