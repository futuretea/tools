#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    gov.sh VERSION
EOF
}

if [ $# -lt 1 ]; then
    useage
    exit
fi

VERSION=$1
OS=$(uname -a | awk '{print $1}')
if [ x"${OS}" != x"Darwin" ]; then
    GOROOT="/usr/local/go"
    sudo rm -f "${GOROOT}"
    GOPACK="${GOROOT}${VERSION}"
    if [ ! -d "${GOPACK}" ]; then
        TEMPDIR=$(mktemp -d)
        sudo wget "https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz" -cP "${HOME}/Downloads/"
        tar -zxf "${HOME}/Downloads/go${VERSION}.linux-amd64.tar.gz" -C "${TEMPDIR}"
        mkdir -p "${TEMPDIR}"
        sudo mv "${TEMPDIR}/go" "${GOPACK}"
        sudo rm -r "${TEMPDIR}"
    fi
    sudo ln -s "${GOPACK}" "${GOROOT}"
fi
GOVERSIONNOW="$(go version | awk '{print $3}' | sed 's/go//g')"
echo "go ${GOVERSIONNOW}"
