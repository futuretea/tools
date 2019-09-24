#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    pod2csv.sh [KUBECTL_OPTIONS]
    读取pod信息,生成以tab分隔的csv文件,以便过滤筛选.
    脚本最后的xdg-open请根据环境替换,类似excel表格软件最好
    可以对出错的pod进行分析,找到出错pod的共性
EOF
}

COLS=(
"NAME:metadata.name"
"NAMESPACE:metadata.namespace"
"NODENAME:spec.nodeName"
"PHASE:status.phase"
"DNSPOLICY:spec.dnsPolicy"
"RESTARTPOLICY:spec.restartPolicy"
"HOSTNETWORK:spec.hostNetwork"
"CONTAINER:spec.containers[*].name"
"INITCONTAINER:spec.initContainers[*].name"
"ENV:spec.containers[*].env[*].name"
"INITENV:spec.initContainers[*].env[*].name"
"IMAGEPULLSECRETS:spec.imagePullSecrets[*].name"
"IMAGE:spec.containers[*].image"
"IMAGEPULLPOLICY:spec.containers[*].imagePullPolicy"
"INITIMAGE:spec.initContainers[*].image"
"INITIMAGEPULLPOLICY:spec.initContainers[*].imagePullPolicy"
"SERVICEACCOUNT:spec.serviceAccount"
"SERVICEACCOUNTNAME:spec.serviceAccountName"
"VOLUMES:spec.volumes[*].name"
"TOLERATIONS:spec.tolerations[*].key"
"HOSTIP:status.hostIP"
"PODIP:status.podIP"
"QOSCLASS:status.qosClass"
"STARTTIME:status.startTime"
)
CUSTOMCOLS=""
for ((i=1;i<=${#COLS[@]};i++ )); do
    if [ ${i} -eq 1 ];then
      CUSTOMCOLS="${COLS[$i-1]}"
    else
      CUSTOMCOLS="${CUSTOMCOLS},${COLS[$i-1]}"
    fi
done
TMPFILE=$(mktemp --suffix=.csv)
kubectl get pod --chunk-size=0 -o custom-columns="${CUSTOMCOLS}" $@ |sed 's/[ ][ ]*/\t/g' >"${TMPFILE}"
xdg-open "${TMPFILE}"