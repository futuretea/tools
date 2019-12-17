#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    kubeprobe.sh TYPE WORKLOAD CONTAINER [READINESSPROBE LIVENESSPROBE ]
    eg: 
      kubeprobe deploy ui nginx
      kubeprobe deploy ui nginx "" "3 2 1 1 3 http / 80"
      kubeprobe deploy ui nginx "10 2 1 1 3 http / 80" "3 2 1 1 3 http / 80"
      kubeprobe deploy ui nginx "10 2 1 1 3 tcp 80"
      kubeprobe deploy ui nginx "10 2 1 1 3 exec ls /"
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    useage
    exit 1
fi

TYPE=$1
WORKLOAD=$2
CONTAINER=$3
READINESSPROBE_CONFIG=${4:-""}
LIVENESSPROBE_CONFIG=${5:-""}

joinCommand() {
    local str=''
    local i=1
    for v in "$@"; do
        str=$str
        if [ $i -ne 1 ]; then
            str=$str','
        fi
        str=$str'"'$v'"'
        i=$((i + 1))
    done
    echo "$str"
}

getProbeSpec() {
    local PROBE_CONFIG=$1
    local PROBE
    local PROBE_ARGS
    local PROBE_METHOD
    local COMMAND
    if [ -n "${PROBE_CONFIG}" ]; then
        PROBE=(${PROBE_CONFIG})
        PROBE_ARGS='"initialDelaySeconds": '${PROBE[0]}',"periodSeconds": '${PROBE[1]}',"successThreshold": '${PROBE[2]}',"timeoutSeconds": '${PROBE[3]}',"failureThreshold": '${PROBE[4]}
        case ${PROBE[5]} in
        "http")
            PROBE_METHOD='"httpGet": {"path": "'${PROBE[6]}'","port": '${PROBE[7]}',"scheme": "HTTP"}'
            ;;
        "tcp")
            PROBE_METHOD='"tcpSocket": {"port": '${PROBE[6]}'}'
            ;;
        "exec")
            COMMAND=$(joinCommand "${PROBE[@]:6}")
            PROBE_METHOD='"exec":{"command": ['${COMMAND}']}'
            ;;
        *)
            echo "unknow method ${PROBE[5]}"
            exit 1
            ;;
        esac
        echo '{'${PROBE_ARGS},${PROBE_METHOD}'}'
    else
        echo "null"
    fi
}

SPEC='{"spec": {"template": {"spec": {"containers": [{"name": "'${CONTAINER}'","livenessProbe":'$(getProbeSpec "${LIVENESSPROBE_CONFIG}")',"readinessProbe":'$(getProbeSpec "${READINESSPROBE_CONFIG}")'}]}}}}'
echo "${SPEC}"
kubectl patch "${TYPE}" "${WORKLOAD}" --patch "${SPEC}"
