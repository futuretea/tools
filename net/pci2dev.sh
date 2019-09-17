#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  pci2dev.sh PCIADDRESS"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

PCIADDRESS=$1
ls /sys/bus/pci/devices/${PCIADDRESS}/net
