#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
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
    useage
    exit 1
fi

VERSION=${1:-"v0.15.2"}
NAME="operator-sdk"
TARGET="operator-sdk-$VERSION-x86_64-linux-gnu"
URL="https://github.com/operator-framework/operator-sdk/releases/download/$VERSION/${TARGET}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
echo $PWD
proxychains wget "${URL}"
chmod +x "${TARGET}"
sudo mv  "${TARGET}" /usr/local/bin/"${NAME}"
cd -
rm -r "${TEMPDIR}"
