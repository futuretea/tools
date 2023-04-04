#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    harvester-patch-images TARGET_REPO TARGET_TAG
HELP
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

COMMIT=$(git rev-parse --short HEAD)
SOURCE_TAG=${COMMIT}-amd64

TARGET_REPO=$1
TARGET_TAG=${2:-${SOURCE_TAG}}

function patch_harvester() {
  local tmp_file="$(mktemp)"
  cat > "${tmp_file}" <<EOF
spec:
  values:
    containers:
      apiserver:
        image:
          repository: ${TARGET_REPO}/harvester
          tag: ${TARGET_TAG}
    webhook:
      image:
        repository: ${TARGET_REPO}/harvester-webhook
        tag: ${TARGET_TAG}
EOF
  kubectl -n fleet-local patch managedchart harvester --patch-file=/tmp/harvester-fix.yaml --type merge
#  kubectl -n harvester-system patch deploy harvester -p '{"metadata":{"annotations":{"management.cattle.io/scale-available":null}}}'
#  kubectl -n harvester-system patch deploy harvester-webhook -p '{"metadata":{"annotations":{"management.cattle.io/scale-available":null}}}'
  kubectl -n harvester-system scale deploy harvester --replicas=0
  kubectl -n harvester-system scale deploy harvester-webhook --replicas=0
  kubectl -n harvester-system delete rs -l app.kubernetes.io/name=harvester
  kubectl -n harvester-system scale deploy harvester --replicas=1
  kubectl -n harvester-system scale deploy harvester-webhook --replicas=1
  kubectl -n harvester-system wait --for=condition=Available deploy harvester
  kubectl -n harvester-system wait --for=condition=Available deploy harvester-webhook
}

function patch_harvester_network_controller() {
  local tmp_file="$(mktemp)"
  cat > "${tmp_file}" <<EOF
spec:
  values:
    harvester-network-controller:
      image:
        repository: ${TARGET_REPO}/harvester-network-controller
        tag: ${TARGET_TAG}
      webhook:
        image:
          repository: ${TARGET_REPO}/harvester-network-webhook
          tag: ${TARGET_TAG}
      helper:
        image:
          repository: ${TARGET_REPO}/harvester-network-helper
          tag: ${TARGET_TAG}
EOF
  kubectl -n fleet-local patch managedchart harvester --patch-file="${tmp_file}" --type merge
  kubectl -n harvester-system scale deploy harvester-network-controller-manager --replicas=0
  kubectl -n harvester-system scale deploy harvester-network-webhook --replicas=0
  kubectl -n harvester-system scale deploy harvester-network-controller-manager --replicas=1
  kubectl -n harvester-system scale deploy harvester-network-webhook --replicas=1
}

function patch_harvester_load_balancer() {
  local tmp_file="$(mktemp)"
  cat > "${tmp_file}" <<EOF
spec:
  values:
    harvester-load-balancer:
      image:
        repository: ${TARGET_REPO}/harvester-load-balancer
        tag: ${TARGET_TAG}
EOF
  kubectl -n fleet-local patch managedchart harvester --patch-file="${tmp_file}" --type merge
  kubectl -n harvester-system scale deploy harvester-load-balancer --replicas=0
  kubectl -n harvester-system scale deploy harvester-load-balancer --replicas=1
}

function patch_harvester_node_disk_manager() {
  local tmp_file="$(mktemp)"
  cat > "${tmp_file}" <<EOF
spec:
  values:
    harvester-node-disk-manager:
      image:
        repository: ${TARGET_REPO}/harvester-node-disk-manager
        tag: ${TARGET_TAG}
EOF
  kubectl -n fleet-local patch managedchart harvester --patch-file="${tmp_file}" --type merge
}

function patch_harvester_node_manager() {
  local tmp_file="$(mktemp)"
  cat > "${tmp_file}" <<EOF
spec:
  values:
    harvester-node-manager:
      image:
        repository: ${TARGET_REPO}/harvester-node-manager
        tag: ${TARGET_TAG}
EOF
  kubectl -n fleet-local patch managedchart harvester --patch-file="${tmp_file}" --type merge
}

repo_name=$(basename ${PWD})

case ${repo_name} in
harvester)
  patch_harvester
  ;;
harvester-network-controller)
  patch_harvester_network_controller
  ;;
load-balancer-harvester)
  patch_harvester_load_balancer
  ;;
harvester-load-balancer)
  patch_harvester_load_balancer
  ;;
node-disk-manager)
  patch_harvester_node_disk_manager
  ;;
harvester-node-disk-manager)
  patch_harvester_node_disk_manager
  ;;
node-manager)
  patch_harvester_node_manager
  ;;
harvester-node-manager)
  patch_harvester_node_manager
  ;;
esac