#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    new VERSION
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 1 ];then
    useage
    exit 1
fi

VERSION=$1
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v${VERSION}/bin/linux/amd64/kubectl"
