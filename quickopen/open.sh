#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  open.sh OPENPATH"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

OPENPATH=$1
if [ -f "${OPENPATH}" ];then
for line in $(cat ${OPENPATH});do
xdg-open ${line} >/dev/null 2>&1
done
else
xdg-open "${OPENPATH}" >/dev/null 2>&1
fi
