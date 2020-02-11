#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    cssh.sh
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

# docker exec -it ssr cat /etc/shadowsocksr.json | jq -r '.server, .server_port' | xargs alive
source $HOME/ssr.alias
alive $SSR_IP $SSR_PORT
