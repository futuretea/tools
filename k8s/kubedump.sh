#!/bin/bash
set -e

useage() {
    echo "useage:"
    echo "  dumpk8s.sh DUMPDIR [NAMESPACE]"
}

if [ $# -lt 1 ]; then
    useage
    exit
fi

DUMPDIR=$1
NAMESPACE=$2

list_names() {
    kubectl -n "${1}" get "${2}" -o custom-columns='NAME:metadata.name' --no-headers
}

dump_workload() {
    local NAMESPACE=$1
    local WORKLOAD_NAME=$2
    local i
    mkdir -p "${DUMPDIR}/${NAMESPACE}/${WORKLOAD_NAME}"
    mapfile -t WORKLOADS < <(list_names "${NAMESPACE}" "${WORKLOAD_NAME}")
    for ((i = 1; i <= ${#WORKLOADS[@]}; i++)); do
        WORKLOAD="${WORKLOADS[$i - 1]}"
        echo "Dumping ${NAMESPACE} ${WORKLOAD_NAME} ${WORKLOAD}"
        kubectl -n "${NAMESPACE}" get "${WORKLOAD_NAME}" "${WORKLOAD}" -o yaml --export >"${DUMPDIR}/${NAMESPACE}/${WORKLOAD_NAME}/${WORKLOAD}.yaml" 2>/dev/null
    done
}

if [ -z "${NAMESPACE}" ]; then
    mapfile -t WORKLOAD_NAMES < <(kubectl api-resources -oname --namespaced=false | grep -vE "(componentstatuses|authentication.k8s.io|authorization.k8s.io)")
    NAMESPACE="default"
else
    mapfile -t WORKLOAD_NAMES < <(kubectl api-resources -oname --namespaced=true | grep -vE "(bindings|secrets|authorization.k8s.io)")
fi
mkdir -p "${DUMPDIR}/${NAMESPACE}"
for ((i = 1; i <= ${#WORKLOAD_NAMES[@]}; i++)); do
    WORKLOAD_NAME="${WORKLOAD_NAMES[$i - 1]}"
    dump_workload "${NAMESPACE}" "${WORKLOAD_NAME}"
done

echo "Done"
