#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  netconf.sh IFACE"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

IFACE=$1
for conf in /proc/sys/net/ipv4/conf/${IFACE}/*
do
echo "$(basename ${conf}) $(cat ${conf})" 
done
