#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    kubenv.sh TYPE NAME [OPTS]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi

TYPE=$1
NAME=$2
shift 2
OPTS=$@

cm_pipline(){
    sed -e 's/^map\[//g' | sed -e 's/\]$//g' | sed -e 's/ /\n/g' | sed -e 's/:/=/' | sed -e 's/^/export /g'
}

secret_pipline(){
    sed -e 's/^map\[//g' | sed -e 's/\]$//g' | sed -e 's/ /\n/g' | awk -F ":" '{printf "export %s=", $1;cmd=sprintf("echo %s | base64 -d", $2);system(cmd);print "";}'
}
if [ x"${TYPE}" == x"secret" ]; then
    kubectl ${OPTS} get "${TYPE}" "${NAME}" -o jsonpath="{.data}" | secret_pipline
else
    kubectl ${OPTS} get "${TYPE}" "${NAME}" -o jsonpath="{.data}" | cm_pipline
    echo ""
fi
