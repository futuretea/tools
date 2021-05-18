#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    alivehook.sh IP PORT CMD
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

IP=$1
PORT=$2
shift 2
CMD=$@

add_time(){
    echo "$@" | awk '{print strftime(" %Y-%m-%d %H:%M:%S", systime())  " " $0}'
}

if nc -w 10 -vz "${IP}" "${PORT}" &>/dev/null; then
    add_time "$IP" "$PORT" "Y"
else
    add_time "$IP" "$PORT" "N"
    $CMD
fi
