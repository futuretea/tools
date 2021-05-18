#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    vmimage.sh HOST NAME VERSION
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

HOST=$1
NAME=$2
VERSION=${3:-"latest"}
TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}"
ssh "${HOST}" tar -cvpf /tmp/system.tar --directory=/ --exclude=proc --exclude=sys --exclude=dev --exclude=run --exclude=boot .
scp "${HOST}":/tmp/system.tar .
docker import system.tar "${NAME}:${VERSION}"
docker save "${NAME}:${VERSION}" -o "./${NAME}-${VERSION}.tar"
