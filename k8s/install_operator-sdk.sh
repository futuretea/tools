#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    install_operator-sdk.sh VERSION
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

REPO="operator-framework/operator-sdk/"
VERSION=${1:-$(releasef ${REPO})}
NAME="operator-sdk"
TARGET="operator-sdk-$VERSION-x86_64-linux-gnu"
URL="https://github.com/${REPO}/releases/download/$VERSION/${TARGET}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
echo $PWD
wget "${URL}"
chmod +x "${TARGET}"
sudo mv  "${TARGET}" /usr/local/bin/"${NAME}"
cd -
rm -r "${TEMPDIR}"
