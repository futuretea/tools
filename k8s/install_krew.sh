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
NAME="krew-$(uname | tr '[:upper:]' '[:lower:]')_amd64"
curl -fsSLO "https://github.com/${REPO}/releases/download/${VERSION}/${NAME}.tar.gz"
tar zxvf ${NAME}.tar.gz
rm LICENSE
chmod +x ${NAME}
sudo mv ${NAME} /usr/local/bin/kubectl-krew
kubectl krew update
