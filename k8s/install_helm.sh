#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    install_helm.sh HELMVERSION
EOF
}

exit_err() {
   echo >&2 "$1"
   exit 1
}

if [ $# -lt 0 ];then
    useage
    exit 1
fi

HELMVERSION=${1:-helm-v3.0.0-beta.3-linux-amd64}
HELMTARBAR=${HELMVERSION}.tar.gz
HELMURL="https://get.helm.sh/${HELMTARBAR}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
proxychains curl -fsSLO "${HELMURL}"
tar -zxvf "${HELMTARBAR}"
mv linux-amd64/helm /usr/local/bin/h3
cd -
rm -r "${TEMPDIR}"


