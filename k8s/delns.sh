#!/bin/bash
set -e

usage() {
    echo "usage:"
    echo "  delns.sh NAMESPACE"
}

if [ $# -lt 1 ]; then
    usage
    exit
fi

NAMESPACE=$1
JSONFILE=${NAMESPACE}.json
kubectl get ns "${NAMESPACE}" -o json >"${JSONFILE}"
vi "${JSONFILE}"
curl -k -H "Content-Type: application/json" -X PUT --data-binary @"${JSONFILE}" \
    http://127.0.0.1:8001/api/v1/namespaces/${NAMESPACE}/finalize
