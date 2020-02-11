#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    install_doctl.sh [VERSION]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

VERSION=${1:-"1.38.0"}
# docker run -it --rm -v /usr/local/bin:/mnt --entrypoint="" digitalocean/doctl:"${VERSION}" cp /app/doctl /mnt
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
wget https://github.com/digitalocean/doctl/releases/download/v$VERSION/doctl-$VERSION-linux-amd64.tar.gz
tar -zxvf doctl-$VERSION-linux-amd64.tar.gz
cp doctl /usr/local/bin/

