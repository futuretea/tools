#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    kubefetch [FOCUS]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

KUBEHOSTFILE=$HOME/kubes.csv
FOCUS=${1:-""}
PORT="6443"
tail --lines=+2 ${KUBEHOSTFILE} | tr ',' ' ' | while read -r CLUSTER TYPE USER HOST ROOTPASS; do
    if [ -z "${CLUSTER}" ]; then
        continue
    fi

    case "${CLUSTER}" in \#*) continue ;; esac

    if [ -n "${FOCUS}" ];then
        if [[ ! "${CLUSTER}" =~ "${FOCUS}" ]];then
            continue
        fi
    fi

    KUBECONFIGFILE=""
    case "${TYPE}" in
      k8s)
        echo "🚤 ${CLUSTER} <= ${USER}@${HOST}"
        if [ x"${USER}" == x"root" ];then
            KUBECONFIGFILE="/root/.kube/config"
        else
            KUBECONFIGFILE="/home/${USER}/.kube/config"
        fi
        ;;
      k3s)
        echo "🚀 ${CLUSTER} <= ${USER}@${HOST}"
        KUBECONFIGFILE="/etc/rancher/k3s/k3s.yaml"
        ;;
      rke2)
        echo "🚄 ${CLUSTER} <= ${USER}@${HOST}"
        KUBECONFIGFILE="/etc/rancher/rke2/rke2.yaml"
        ;;
      *)
        ;;
    esac
    LOCALKUBECONFIGFILE="${HOME}/.kube/${CLUSTER}.config"

    if [ ${ROOTPASS} ];then
        echo ${ROOTPASS} | ssh -n -tt ${USER}@${HOST} sudo cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
        sed -i "1,2d" "${LOCALKUBECONFIGFILE}"
    else
        ssh -n ${USER}@${HOST} sudo cat ${KUBECONFIGFILE} >"${LOCALKUBECONFIGFILE}"
        sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
    fi

    if [ ! -f "${HOME}/.kube/config" ];then
        touch "${HOME}/.kube/config"
    fi

    if grep -qE ^${CLUSTER}$ < <(kubectl config get-contexts -o 'name');then
        kubectl config delete-context ${CLUSTER}
    fi

    kubecm add -c -f "${LOCALKUBECONFIGFILE}" >/dev/null 2>&1

    kubectl config use-context ${CLUSTER}

    echo "✅ ${CLUSTER}"
done