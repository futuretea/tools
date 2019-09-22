#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    alive.sh IP PORT
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 2 ];then
    useage
    exit 1
fi

IP=$1
PORT=$2

if ping -c 1 -i 0.3 -W 1 "${IP}" &>/dev/null;then
  if nc -w 10 -vzn "${IP}" "${PORT}" &>/dev/null;then
    echo "Service is alived."
  else
    echo "Port is closed."
  fi
else
  echo "IP is unaccessible."
fi