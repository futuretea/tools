#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    kubefetch.sh FOCUS
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

KUBEHOSTFILE=$HOME/kubehost
FOCUS=${1:-""}
while read -r CLUSTER TYPE SSH_PROXY SSH_CONFIG HOST PORT ROOTPASS;do
    if [ -n "${FOCUS}" ] && [ x"${FOCUS}" != x"${CLUSTER}" ];then
        continue
    fi
    if [ -z "${CLUSTER}" ];then
        continue
    fi

    echo "[ ${CLUSTER} ]  "

    KUBECONFIGFILE=""
    if [ x"${TYPE}" == x"k3s" ];then
        KUBECONFIGFILE="/etc/rancher/k3s/k3s.yaml"
    else
        KUBECONFIGFILE="/root/.kube/config"
    fi
    LOCALKUBECONFIGFILE="${HOME}/.kube/config.${CLUSTER}"

    if [ ${ROOTPASS} ];then
        if [ x${SSH_PROXY} != x"-" ];then
            echo $ROOTPASS | ssh -o "ProxyCommand=nc -X 5 -x ${SSH_PROXY} %h %p" -tt ${SSH_CONFIG} sudo cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        else
            echo $ROOTPASS | ssh -tt ${SSH_CONFIG} sudo cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        fi
        sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
        sed -i "1,2d" "${LOCALKUBECONFIGFILE}"
    else
        if [ x${SSH_PROXY} != x"-" ];then
            ssh -o "ProxyCommand=nc -X 5 -x ${SSH_PROXY} %h %p" ${SSH_CONFIG} cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        else
            ssh ${SSH_CONFIG} cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        fi
         sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
    fi

    echo "[ ${CLUSTER} ] finish "

done < ${KUBEHOSTFILE}


