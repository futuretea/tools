#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    init_nonet.sh
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi
sudo groupadd nonet
sudo iptables -A OUTPUT -m owner --gid-owner nonet -j DROP
sudo gpasswd -a $USER nonet
