#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    glk.sh URL [LOCALPATH]
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 1 ];then
    useage
    exit 1
fi

URL=$1
LOCALPATH=${2:-$(echo "${URL}" | awk -F "/" '{print $NF}')}
proxychains git clone "${URL}".git "${LOCALPATH}"
cd "${LOCALPATH}"
gck
code .
gop .



