#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    vmbox.sh PROJECT BOX VERSION PROVIDER
    eg vmbox centos 7 1905.1 libvirt
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 4 ]; then
    usage
    exit 1
fi

PROJECT=$1
BOX=$2
VERSION=$3
PROVIDER=$4

wget https://vagrantcloud.com/"${PROJECT}"/boxes/"${BOX}"/versions/${VERSION}/providers/${PROVIDER}.box \
    -O "${PROJECT}-${BOX}-${VERSION}-${PROVIDER}.box"
