#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    kubecheck.sh 
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

check_node() {
    kubectl get node --field-selector=status.phase!=Running
}
check_cs() {
    kubectl get cs
}

check_node
check_cs
