#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    pod2xsv.sh [KUBECTL_OPTIONS] | xsv stats
    读取pod信息,通过管道传给xsv进行处理(https://github.com/BurntSushi/xsv)
    实例:
      # 列统计
      pod2xsv.sh | xsv stats
      # 行统计
      pod2xsv.sh | xsv count
      # 一行一个字段展示
      pod2xsv.sh | xsv flatten
      # 查找非Running的pod
      pod2xsv.sh | xsv search -v -s PHASE Running | xsv flatten
      # 显示pod网络情况
      pod2xsv.sh | xsv select NAME,NAMESPACE,HOSTNETWORK,DNSPOLICY | xsv table
      # 显示HOSTNETWORK为true但DNSPOLICY不为ClusterFirstWithHostNet的pod
      pod2xsv.sh | xsv search -s HOSTNETWORK true | xsv search -v -s DNSPOLICY ClusterFirstWithHostNet | xsv select NAME,NAMESPACE,HOSTNETWORK,DNSPOLICY | xsv table
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
kubectl get pod --chunk-size=0 -o custom-columns="${CUSTOMCOLS}" $@ |sed 's/[ ][ ]*/\t/g' | xsv cat rows -d '\t'