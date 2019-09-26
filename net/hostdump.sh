#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
# set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    hostdump.sh TARGET IFACE [OPTIONS...]
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

LOCAL_TCPDUMP=/usr/local/bin/static-tcpdump
REMOTE_TCPDUMP=/tmp/static-tcpdump
TARGET=$1
IFACE=$2
shift 2
if sshpass -e "${TARGET}" [[ ! -f "${REMOTE_TCPDUMP}" ]];then
  sshpass -e scp "${LOCAL_TCPDUMP}"  "${TARGET}":"${REMOTE_TCPDUMP}"
fi 
sshpass -e ssh "${TARGET}" "${REMOTE_TCPDUMP}" -i "${IFACE}" -U -w - $@ | /bin/sh -c "sudo wireshark -k -i -"
