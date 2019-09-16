#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  delns.sh NAMESPACE"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

NAMESPACE=$1
JSONFILE=${NAMESPACE}.json
kubectl get ns "${NAMESPACE}" -o json > "${JSONFILE}"
vi "${JSONFILE}"
curl -k -H "Content-Type: application/json" -X PUT --data-binary @"${JSONFLE}" http://127.0.0.1:8001/api/v1/namespaces/"${NAMESPACE}"/finalize
