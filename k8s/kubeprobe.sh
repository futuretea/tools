#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    kubeprobe.sh TYPE WORKLOAD CONTAINER probe path port initialDelaySeconds [periodSeconds timeoutSeconds successThreshold failureThreshold]
    eg: kubeprobe deploy ui nginx / 80 3 2 1 1 3
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 10 ];then
    useage
    exit 1
fi

TYPE=$1
WORKLOAD=$2
CONTAINER=$3
path=$4
port=$5
initialDelaySeconds=$6
periodSeconds=${7:-10}
timeoutSeconds=${8:-1}
successThreshold=${9:-1}
failureThreshold=${10:-3}

PROBE='{"failureThreshold": '$failureThreshold',"httpGet": {"'$path'": "/","port": '$port',"scheme": "HTTP"},"initialDelaySeconds": '$initialDelaySeconds',"periodSeconds": '$periodSeconds',"successThreshold": '$successThreshold',"timeoutSeconds": '$timeoutSeconds'}'

SPEC='{"spec": {"template": {"spec": {"containers": [{"name": "'${CONTAINER}'","livenessProbe":'${PROBE}',"readinessProbe":'${PROBE}'}]}}}}'

kubectl patch "${TYPE}" "${WORKLOAD}" --patch "${SPEC}"
