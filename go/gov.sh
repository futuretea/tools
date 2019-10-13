#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    gov.sh VERSION
EOF
}

if [ $# -lt 1 ];then
    useage
    exit
fi

VERSION=$1
if [ -z "${GOROOT}" ];then
  GOROOT="/usr/local/bin/go"
fi
sudo rm -f "${GOROOT}"
GOPACK="${GOROOT}${VERSION}"
if [ ! -d "${GOPACK}" ];then
  sudo wget "https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz" -cP "${HOME}/Downloads/"
  TEMPDIR=$(mktemp -d)
  tar -zxf "${HOME}/Downloads/go${VERSION}.linux-amd64.tar.gz" -C "${TEMPDIR}"
  mkdir -p "${TEMPDIR}"
  sudo mv "${TEMPDIR}/go" "${GOPACK}"
  sudo rm -r "${TEMPDIR}"
fi
sudo ln -s "${GOPACK}" "${GOROOT}"
GOVERSIONNOW="$(go version | awk '{print $3}' | sed 's/go//g')"
echo "go ${GOVERSIONNOW}"
