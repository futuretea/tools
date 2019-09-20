#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  kubefetch.sh NAME [HOST]"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

NAME=$1
HOST=${2:-$1}
ssh root@${HOST} cat /root/.kube/config | sed "s/server: https:\/\/.*:6443/server: https:\/\/${HOST}:6443/g" >~/.kube/config.${NAME}