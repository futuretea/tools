#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

useage() {
    cat <<HELP
USAGE:
    kf.sh SSH_CONFIG CLUSTER
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi

SSH_CONFIG=$1
CLUSTER=$2
HOST=${3:-""}
PORT=${4:-""}

KUBECONFIGS=(
    "/etc/rancher/k3s/k3s.yaml"
    "/root/.kube/config"
)
KUBECONFIGFILE=""
for ((i = 1; i <= ${#KUBECONFIGS[@]}; i++)); do
    ssh ${SSH_CONFIG} "[ -f ${KUBECONFIGS[$i - 1]} ]"
    if [ $? -eq 0 ]; then
        KUBECONFIGFILE=${KUBECONFIGS[$i - 1]}
        break
    fi
done
LOCALKUBECONFIGFILE="${HOME}/.kube/config.${CLUSTER}"
SSHPASS=${SSHPASS:-""}
if [ ${SSHPASS} ];then
echo $SSHPASS | ssh -tt ${SSH_CONFIG} sudo cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
else
ssh ${SSH_CONFIG} cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
fi
if [ $# -eq 3 ]; then
    sed -i "s/server: https:\/\/.*:/server: https:\/\/${HOST}:/g" "${LOCALKUBECONFIGFILE}"
elif [ $# -eq 4 ]; then
    sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
fi
