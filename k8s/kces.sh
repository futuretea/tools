#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

useage() {
    cat <<HELP
USAGE:
    kces.sh CMDLINE
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit 1
fi
CMDLINE=$@
kubectl get pod --field-selector=status.phase==Running -o custom-columns='NAME:metadata.name,CONTAINER:spec.containers[*].name' --no-headers | while read -r line;do
    arr=(${line/,/ })
    num=${#arr[@]}
    for ((i=1;i<num;i++));do
        pod="${arr[0]}"
        container="${arr[i]}"
        echo "[${pod}/${container}]"
        kubectl exec "${pod}" -c "${container}" ${CMDLINE}
        echo -e "\n"
    done
done