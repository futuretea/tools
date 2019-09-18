#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  goc.sh CODEPATH"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

CODEPATH=$1
shift 1
codemod -m -d "${CODEPATH}" --extensions go $@
