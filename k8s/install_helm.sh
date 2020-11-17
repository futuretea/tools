#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    install_helm.sh HELMVERSION
EOF
}

exit_err() {
    echo >&2 "$1"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

REPO="helm/helm"
VERSION=$(releasef ${REPO})
HELMVERSION=${1:-helm-${VERSION}-linux-amd64}
HELMTARBAR=${HELMVERSION}.tar.gz
HELMURL="https://get.helm.sh/${HELMTARBAR}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
curl -fsSLO "${HELMURL}"
tar -zxvf "${HELMTARBAR}"
sudo mv linux-amd64/helm /usr/local/bin/h3
cd -
rm -r "${TEMPDIR}"

h3 repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
h3 repo update
