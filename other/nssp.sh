#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    nssp.sh [NEWSSPORT]
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

function rand() {
    local min=$1
    local max=$(($2 - min + 1))
    local num
    num=$(cksum /proc/sys/kernel/random/uuid | awk -F ' ' '{print $1}')
    echo $((num % max + min))
}

NEWSSPORT=${1:-$(rand 49152 65535)}

sed -ri "s/server_port\":[0-9]+/server_port\":${NEWSSPORT}/g" /etc/shadowsocks.json
/etc/init.d/shadowsocks restart
echo "new ss listen port: ${NEWSSPORT}"
