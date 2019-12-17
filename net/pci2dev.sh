#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    pci2dev.sh PCIADDRESS
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit
fi

PCIADDRESS=$1
ls /sys/bus/pci/devices/${PCIADDRESS}/net
