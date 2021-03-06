#!/bin/bash
set -e

usage() {
    echo "usage:"
    echo "  kubevi.sh NAMESPACE POD CONTAINER REMOTE"
}

if [ $# -ne 4 ]; then
    usage
    exit
fi

NAMESPACE=$1
POD=$2
CONTAINER=$3
REMOTE=$4
LOCAL=$(basename "${REMOTE}")
TEMPDIR=$(mktemp -d)
echo "${TEMPDIR}"
cd "${TEMPDIR}"
kubectl -n "${NAMESPACE}" cp "${POD}":"${REMOTE}" "${LOCAL}" -c "${CONTAINER}"
LOCALMD51=$(md5sum "${LOCAL}" | awk '{print $1}')
vi "${LOCAL}"
LOCALMD52=$(md5sum "${LOCAL}" | awk '{print $1}')
if [ x"${LOCALMD51}" != x"${LOCALMD52}" ]; then
    kubectl -n "${NAMESPACE}" cp "${LOCAL}" "${POD}":"${REMOTE}" -c "${CONTAINER}"
fi
rm "${LOCAL}"
