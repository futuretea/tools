#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    install_doctl.sh VERSION
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

VERSION=$1
docker run -it --rm -v /usr/local/bin:/mnt --entrypoint="" digitalocean/doctl:"${VERSION}" cp /app/doctl /mnt