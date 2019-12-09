#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    vmbox.sh PROJECT BOX VERSION PROVIDER
    eg vmbox.sh ubuntu trusty64 20190514.0.0 virtualbox
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 4 ];then
    useage
    exit 1
fi

PROJECT=$1
BOX=$2
VERSION=$3
PROVIDER=$4

proxychains wget https://vagrantcloud.com/"${PROJECT}"/boxes/"${BOX}"/versions/${VERSION}/providers/${PROVIDER}.box \
  -O "${PROJECT}-${BOX}-${VERSION}-${PROVIDER}.box"
