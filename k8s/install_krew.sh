#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    install_krew.sh [VERSION]
EOF
}

exit_err() {
    echo >&2 "$1"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

cd "$(mktemp -d)"
REPO="kubernetes-sigs/krew"
VERSION=${1:-$(releasef ${REPO})}
curl -fsSLO "https://github.com/${REPO}/releases/download/${VERSION}/krew.{tar.gz,yaml}"
tar zxvf krew.tar.gz
./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install --manifest=krew.yaml --archive=krew.tar.gz
kubectl krew update
