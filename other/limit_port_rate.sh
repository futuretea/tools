#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    limit_port_rate.sh CLEAN PORT [RATE] [NIC] [MARK]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi

CLEAN=$1
PORT=$2
RATE=${3:-1}
NIC=${4:-eth0}
MARK=${5:-5}

if [ $CLEAN == "true" ];then
# clean tc rules
tc qdisc del dev $NIC root
tc -s qdisc ls dev $NIC

# clean iptables mangle rules
iptables -t mangle -F
fi

# add iptables mangle rules
iptables -A OUTPUT -t mangle -p tcp --sport $PORT -j MARK --set-mark $MARK

# add tc rules
tc qdisc add dev $NIC root handle 1: htb
tc class add dev $NIC parent 1: classid 1:$MARK htb rate ${RATE}Mbps ceil ${RATE}Mbps prio 1
tc filter add dev $NIC parent 1:0 protocol ip handle $MARK fw flowid 1:$MARK

# show tc rules
tc qdisc ls dev $NIC
tc -s qdisc ls dev $NIC
tc class ls dev $NIC
tc -s class ls dev $NIC

# show iptables mangle rules
iptables -t mangle -n -v -L