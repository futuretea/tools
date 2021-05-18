#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    locapv.sh NAME HOSTNAME DIR SIZE [MODE] [POLICY]
    eg: locapv local-pv-sdc 172.172.100.101 /mnt/pv 10Gi ReadWriteOnce Retain
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 4 ]; then
    usage
    exit 1
fi

NAME=$1
HOSTNAME=$2
DIR=$3
SIZE=$4
MODE=${5:-"ReadWriteMany"}
POLICY=${6:-"Delete"}

TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
cat > storage-class.yml <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
cat >local-pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $NAME
spec:
  capacity:
    storage: $SIZE
  accessModes:
  - $MODE
  persistentVolumeReclaimPolicy: $POLICY
  storageClassName: local-storage
  volumeMode: Filesystem
  local:
    fsType: ""
    path: $DIR
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $HOSTNAME
EOF
kubectl apply -f .
cd -
rm -r "${TEMPDIR}"
