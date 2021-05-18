#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    alive.sh IP PORT
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

IP=$1
PORT=$2

echo "Checking ${IP}:${PORT}"

if ping -c 1 -i 0.3 -W 1 "${IP}" &>/dev/null; then
    echo "[*] ping "
else
    echo "[ ] ping"
fi

if sudo hping3 -c 1 -S "${IP}" -p "${PORT}" &>/dev/null; then
    echo "[*] hping3"
else
    echo "[ ] hping3"
fi

if nc -w 10 -vz "${IP}" "${PORT}" &>/dev/null; then
    echo "[*] nc"
else
    echo "[ ] nc"
fi
