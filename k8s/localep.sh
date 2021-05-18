#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    localep.sh NAME [ETH:-wifi0] [PORT:-8081]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

patch(){
	local name=$1
	local ip=$2
	local port=$3
	kubectl patch endpoints ${name} --type='json' -p='[{"op": "replace", "path": "/subsets/0/addresses/0/ip", "value":"'${ip}'"},{"op": "replace", "path": "/subsets/0/ports/0/port", "value":'${port}'}]'
}

NAME=$1
ETH=${2:-"wifi0"}
PORT=${3:-8081}
IP=$(ifconfig "${ETH}" | grep netmask | awk '{print $2}')
OLD_IP=$(kubectl get ep ${NAME} -o jsonpath='{.subsets[0].addresses[0].ip}')
OLD_PORT=$(kubectl get ep ${NAME} -o jsonpath='{.subsets[0].ports[0].port}')
trap "patch $NAME $OLD_IP $OLD_PORT" SIGINT
patch $NAME $IP $PORT
tail -f /dev/null
