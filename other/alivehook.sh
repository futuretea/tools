#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    alivehook.sh IP PORT CMD
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi

IP=$1
PORT=$2
shift 2
CMD=$@

echo "Checking ${IP}:${PORT}"

if nc -w 10 -vz "${IP}" "${PORT}" &>/dev/null; then
    echo "[*] nc"
else
    echo "[ ] nc"
    $CMD
fi
