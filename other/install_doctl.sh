#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
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
    usage
    exit 1
fi

REPO="digitalocean/doctl"
VERSION=${1:-$(releasef ${REPO})}
# docker run -it --rm -v /usr/local/bin:/mnt --entrypoint="" digitalocean/doctl:"${VERSION}" cp /app/doctl /mnt
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
wget https://github.com/${REPO}/releases/download/${VERSION}/doctl-${VERSION#v}-linux-amd64.tar.gz
tar -zxvf doctl-${VERSION#v}-linux-amd64.tar.gz
sudo cp doctl /usr/local/bin/
