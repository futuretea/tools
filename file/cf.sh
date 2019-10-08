#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    cf.sh FILE EXT
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 2 ];then
    useage
    exit 1
fi

FILE=$1
EXT=$2
rm -rf "${FILE}"
ln -s "${FILE}"."${EXT}" "${FILE}"


