#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    kubectl-fetch [CONTEXT]
or
    kubectl fetch [CONTEXT]

NOTE: https://github.com/sunny0826/kubecm is requied to merge contexts

1. put kubectl-fetch to your PATH
2. write the kubectl-fetch config file

the location of kubectl-fetch config file is ~/.config/kubectl-fetch/config.csv
It's a csv format file.
col 1: the name of kubeconfig context
col 2: cluster type, must in (k8s,k3s,rke2)
col 3: the username to fetch kubeconfig file
col 4: the host to fetch kubeconfig file

e.g.:
name,type,user,host
cluster1,k8s,root,192.168.5.100
cluster2,k3s,rancher,192.168.5.101
cluster3,rke2,rancher,192.168.5.102

3. run 'kubectl fetch' to fetch all contexts from remote hosts by ssh
or
   run 'kubectl fetch <context_name>' to fetch a specify context
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

CONFIGDIR="${HOME}/.config/kubectl-fetch"
CONFIGFILE="${CONFIGDIR}/config.csv"
NAME=${1:-""}
PORT="6443"

mkdir -p "${CONFIGDIR}"
if [ ! -f "${CONFIGFILE}" ];then
    echo "can not find the kubectl-fetch config file: ${CONFIGFILE}"
    usage
    exit 1
fi

HAS_KUBECM=false
type kubecm >/dev/null 2>&1
if [ $? -eq 0 ]; then
    HAS_KUBECM=true
fi

tail --lines=+2 "${CONFIGFILE}" | tr ',' ' ' | while read -r CONTEXT TYPE USER HOST ROOTPASS; do
    if [ -z "${CONTEXT}" ]; then
        continue
    fi

    case "${CONTEXT}" in \#*) continue ;; esac

    if [ -n "${NAME}" ];then
        if [[ ! "${CONTEXT}" =~ ${NAME} ]];then
            continue
        fi
    fi

    KUBECONFIGFILE=""
    case "${TYPE}" in
      k8s)
        echo "🚤 ${CONTEXT} <= ${USER}@${HOST}"
        if [ "${USER}" == "root" ];then
            KUBECONFIGFILE="/root/.kube/config"
        else
            KUBECONFIGFILE="/home/${USER}/.kube/config"
        fi
        ;;
      k3s)
        echo "🚀 ${CONTEXT} <= ${USER}@${HOST}"
        KUBECONFIGFILE="/etc/rancher/k3s/k3s.yaml"
        ;;
      rke2)
        echo "🚄 ${CONTEXT} <= ${USER}@${HOST}"
        KUBECONFIGFILE="/etc/rancher/rke2/rke2.yaml"
        ;;
      *)
        ;;
    esac
    LOCALKUBECONFIGFILE="${HOME}/.kube/${CONTEXT}.config"

    if [ "${ROOTPASS}" ];then
        echo "${ROOTPASS}" | ssh -n -tt "${USER}@${HOST}" sudo cat "${KUBECONFIGFILE}" >"${LOCALKUBECONFIGFILE}"
        sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
        sed -i "1,2d" "${LOCALKUBECONFIGFILE}"
    else
        ssh -n "${USER}@${HOST}" sudo cat "${KUBECONFIGFILE}" >"${LOCALKUBECONFIGFILE}"
        sed -i "s/server: https:\/\/.*/server: https:\/\/${HOST}:${PORT}/g" "${LOCALKUBECONFIGFILE}"
    fi

    echo "${CONTEXT}: export KUBECONFIG=${LOCALKUBECONFIGFILE}"
    

    if [ "${HAS_KUBECM}" == "false" ];then
        continue
    fi

    if [ ! -f "${HOME}/.kube/config" ];then
        touch "${HOME}/.kube/config"
    fi

    if grep -qE ^"${CONTEXT}"$ < <(kubectl config get-contexts -o 'name');then
        kubectl config delete-context "${CONTEXT}" >/dev/null 2>&1
    fi

    kubecm add -c -f "${LOCALKUBECONFIGFILE}" >/dev/null 2>&1

    kubectl config use-context "${CONTEXT}" >/dev/null 2>&1
done