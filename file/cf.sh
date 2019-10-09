#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    cf.sh FILE BASE [EXTS..]
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
BASE=$2
shift 2
cat "${FILE}.${BASE}" > "${FILE}"
for EXT in $@;do
cat "${FILE}.${EXT}" >> "${FILE}"
done


