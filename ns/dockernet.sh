#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  dockernet.sh CONTAINER COMMAND [ARG]..."
}

if [ $# -lt 2 ];then
    useage
    exit
fi

CONTAINER=$1
shift 1
PID=$(docker inspect --format "{{.State.Pid}}" "${CONTAINER}")
mkdir -p /var/run/netns
rm -rf /var/run/netns/"${CONTAINER}"
ln -s /proc/"${PID}"/ns/net /var/run/netns/"${CONTAINER}"
ip netns exec "${CONTAINER}" $@
