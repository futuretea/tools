#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    new HTTP SECOND
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 2 ];then
    useage
    exit 1
fi

HTTP=$1
SECOND=$2
echo "kcachegrind" | go tool pprof http://${HTTP}/debug/pprof/profile -seconds ${SECOND}
