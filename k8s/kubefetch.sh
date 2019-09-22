#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  kubefetch.sh SSH_CONFIG CLUSTER [HOST] [PORT]"
    echo "eg:"
    echo "  kubefetch dev{,}"
    echo "  kubefetch dev{,,}"
    echo "  kubefetch dev{,,} 8443"
    echo "  kubefetch tom-pc dev dev-master1 18888"
}

if [ $# -lt 2 ];then
    useage
    exit
fi
SSH_CONFIG=$1
CLUSTER=$2
HOST=$3
PORT=$4

if [ $# -eq 2 ];then
    ssh "${SSH_CONFIG}" cat /root/.kube/config >~/.kube/config."${CLUSTER}"
elif [ $# -eq 3 ];then
    ssh "${SSH_CONFIG}" cat /root/.kube/config | sed "s/server: https:\/\/.*:/server: https:\/\/${HOST}:/g"  >~/.kube/config."${CLUSTER}"
elif [ $# -eq 4 ];then
    ssh "${SSH_CONFIG}" cat /root/.kube/config | sed "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" >~/.kube/config."${CLUSTER}"
fi
