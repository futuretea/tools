#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  kubevi.sh NAMESPACE POD CONTAINER REMOTE"
}

if [ $# -ne 4 ];then
    useage
    exit
fi

NAMESPACE=$1
POD=$2
CONTAINER=$3
REMOTE=$4
LOCAL=$(basename "${REMOTE}")

kubectl -n "${NAMESPACE}" -controller cp "${POD}":"${REMOTE}" "${LOCAL}" -c "${CONTAINER}"
vi "${LOCAL}"
kubectl -n "${NAMESPACE}" -controller cp "${LOCAL}" "${POD}":"${REMOTE}" -c "${CONTAINER}"
rm "${LOCAL}"

