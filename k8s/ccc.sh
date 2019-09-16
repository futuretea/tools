#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  ccc.sh EXT"
}

if [ $# -lt 1 ];then
    useage
    exit
fi
EXT=$1
rm -rf ~/.kube/config
ln -s ~/.kube/config."${EXT}" ~/.kube/config

