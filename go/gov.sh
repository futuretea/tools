#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

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
sudo rm -f "${GOROOT}"
sudo ln -s "${GOROOT}${VERSION}" "${GOROOT}"
GOVERSIONNOW="$(go version | awk '{print $3}' | sed 's/go//g')"
echo "go ${GOVERSIONNOW}"