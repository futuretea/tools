#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

usage() {
    cat <<HELP
USAGE:
    limit_port_rate.sh INIT MARK NIC PORT RATE
    ./limit_port_rate.sh true 10 eth0 10000 10Kbps
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 5 ]; then
    usage
    exit 1
fi

INIT=$1
MARK=$2
NIC=$3
PORT=$5
RATE=$6
shift 6

if [ $INIT == "true" ];then
    # clean tc rules
    tc qdisc del dev $NIC root

    set -e
    tc -s qdisc ls dev $NIC

    # clean iptables mangle rules
    iptables -t mangle -F

    # root qdisc 0
    tc qdisc add dev $NIC root handle 1:0 htb default 1

    # root class 1
    tc class add dev $NIC parent 1:0 classid 1:1 htb rate 1000Mbps
fi

set -e
# limit class
tc class add dev $NIC parent 1:1 classid 1:${MARK} htb rate ${RATE} ceil ${RATE} prio 1
#tc qdisc add dev $NIC parent 1:${MARK} handle ${MARK}: sfq perturb 10
tc qdisc add dev $NIC parent 1:${MARK} handle ${MARK}: netem $@

# match filter
tc filter add dev $NIC parent 1:0 prio 1 protocol ip u32 match ip dport $PORT 0xffff flowid 1:${MARK}

# iptables filter
#tc filter add dev $NIC parent 1:0 protocol ip handle $MARK fw flowid 1:$MARK
#iptables -t mangle -A OUTPUT -p tcp --sport $PORT -j MARK --set-mark $MARK

# show tc rules
tc qdisc ls dev $NIC
tc -s qdisc ls dev $NIC
tc class ls dev $NIC
tc -s class ls dev $NIC

# show iptables mangle rules
iptables -t mangle -n -v -L
