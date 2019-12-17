#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    new TYPE WORKLOAD CONTAINER IMAGE
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 4 ]; then
    useage
    exit 1
fi

TYPE=$1
WORKLOAD=$2
CONTAINER=$3
IMAGE=$4

SPEC='{"spec": {"template": {"spec": {"containers": [{"name": "'"${CONTAINER}"'","image": "'"${IMAGE}"'"}]}}}}'

kubectl patch "${TYPE}" "${WORKLOAD}" --patch "${SPEC}"
