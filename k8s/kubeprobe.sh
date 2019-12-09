#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    kubeprobe.sh TYPE WORKLOAD CONTAINER [LIVENESSPROBE READINESSPROBE]
    eg: 
      kubeprobe deploy ui nginx
      kubeprobe deploy ui nginx "" "/ 80 3 2 1 1 3"
      kubeprobe deploy ui nginx "/ 80 10 2 1 1 3" "/ 80 3 2 1 1 3"
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 3 ];then
    useage
    exit 1
fi

TYPE=$1
WORKLOAD=$2
CONTAINER=$3
LIVENESSPROBE_CONFIG=${4:-""}
READINESSPROBE_CONFIG=${5:-""}

SPEC='{"spec": {"template": {"spec": {"containers": [{"name": "'${CONTAINER}'"'

if [ -n "${LIVENESSPROBE_CONFIG}" ];then
  LIVENESSPROBE=(${LIVENESSPROBE_CONFIG})
  LIVENESSPROBE_SPEC='{"httpGet": {"path": "'${LIVENESSPROBE[0]}'","port": '${LIVENESSPROBE[1]}',"scheme": "HTTP"},"initialDelaySeconds": '${LIVENESSPROBE[2]}',"periodSeconds": '${LIVENESSPROBE[3]}',"successThreshold": '${LIVENESSPROBE[4]}',"timeoutSeconds": '${LIVENESSPROBE[5]}',"failureThreshold": '${LIVENESSPROBE[6]}'}'
  SPEC=${SPEC}',"livenessProbe":'${LIVENESSPROBE_SPEC}
else
  SPEC=${SPEC}',"livenessProbe":null'
fi
if [ -n "${READINESSPROBE_CONFIG}" ];then
  READINESSPROBE=(${READINESSPROBE_CONFIG})
  READINESSPROBE_SPEC='{"httpGet": {"path": "'${READINESSPROBE[0]}'","port": '${READINESSPROBE[1]}',"scheme": "HTTP"},"initialDelaySeconds": '${READINESSPROBE[2]}',"periodSeconds": '${READINESSPROBE[3]}',"successThreshold": '${READINESSPROBE[4]}',"timeoutSeconds": '${READINESSPROBE[5]}',"failureThreshold": '${READINESSPROBE[6]}'}'
  SPEC=${SPEC}',"readinessProbe":'${READINESSPROBE_SPEC}
else
  SPEC=${SPEC}',"readinessProbe":null'
fi
SPEC=${SPEC}'}]}}}}'
echo "${SPEC}"
kubectl patch "${TYPE}" "${WORKLOAD}" --patch "${SPEC}"
