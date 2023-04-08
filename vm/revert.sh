#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    revert VMNAME SNAPSHOTNAME
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

VMNAME=$1
SNAPSHOTNAME=$2

govc snapshot.revert -vm ${VMNAME} ${SNAPSHOTNAME}
