#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
    cat <<"EOF"
USAGE:
    netconf.sh IFACE
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ];then
    useage
    exit
fi

IFACE=$1
for conf in "/proc/sys/net/ipv4/conf/${IFACE}"/*
do
    echo "$(basename "${conf}") $(cat "${conf}")"
done
