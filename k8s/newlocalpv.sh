#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    newlocalpv.sh HOST BASE NAME [SIZE]
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

HOST=$1
BASE=$2
NAME=$3
SIZE=${4:-"10"}

TEMPDIR=$(mktemp -d)
echo "${TEMPDIR}"/"${NAME}".yaml
cd "${TEMPDIR}"
cat > "${NAME}".yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${NAME}
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${SIZE}Gi
  local:
    fsType: ""
    path: ${BASE}/${NAME}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${HOST}
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local
  volumeMode: Filesystem
EOF
ssh "${HOST}" mkdir -p "${BASE}/${NAME}"
kubectl apply -f "${NAME}".yaml