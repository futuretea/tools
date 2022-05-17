#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    pv.sh NAME NAMESPACE
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi


NAME=$1
NAMESPACE=${2:-`kubectl config view --minify -o jsonpath='{..namespace}'`}


INFO(){
    echo -e "\033[32;1m"$1"\033[0m"
}

kubectl -n ${NAMESPACE} get po ${NAME} -owide

POD_JSON=$(kubectl -n ${NAMESPACE} get po ${NAME} -ojson)

INFO "labels" 
echo ${POD_JSON} | jq -r '.metadata.labels'
echo

INFO "annotations" 
echo ${POD_JSON} | jq -r '.metadata.annotations'
echo

INFO "ownerReferences" 
echo ${POD_JSON} | jq -r '.metadata.ownerReferences'
echo

INFO "containers" 
echo ${POD_JSON} | jq -r '.spec.containers'
echo

INFO "volumes" 
echo ${POD_JSON} | jq -r '.spec.volumes'
echo

echo ${POD_JSON} | jq -r '.metadata.ownerReferences | map(select(.kind == "VirtualMachineInstance")) | .[].name' | while read -r vmi_name;do
INFO "vmi ${vmi_name}" 
kubectl -n ${NAMESPACE} get vmi ${vmi_name} -owide
done

echo ${POD_JSON} | jq -r '.spec.volumes | map(select(.persistentVolumeClaim != null)) | .[].persistentVolumeClaim.claimName' | while read -r pvc_name;do
PVC_JSON=$(kubectl -n ${NAMESPACE} get pvc ${pvc_name} -ojson)
pv_name=$(echo ${PVC_JSON} | jq -r '.spec.volumeName')
storageClassName=$(echo ${PVC_JSON} | jq -r '.spec.storageClassName')
INFO "pvc ${pvc_name}" 
kubectl -n ${NAMESPACE} get pvc ${pvc_name} -owide
echo
kubectl -n ${NAMESPACE} get pv ${pv_name} -owide
echo
kubectl get sc ${storageClassName} -owide
echo
done

echo ${POD_JSON} | jq -r '.spec.volumes | map(select(.configMap != null)) | .[].configMap.name' | while read -r cm_name;do
INFO "configmap ${cm_name}" 
kubectl -n ${NAMESPACE} get cm ${cm_name} -oyaml
done

echo ${POD_JSON} | jq -r '.spec.volumes | map(select(.hostPath != null)) | .[].hostPath.path' | while read -r host_path;do
INFO "hostpath ${host_path}" 
done