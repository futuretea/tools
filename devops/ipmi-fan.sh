#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    ipmi-fan host username password speed
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 4 ]; then
    usage
    exit 1
fi


host=$1
username=$2
password=$3
speed=$4


ipmitool -I lanplus -H "${host}" -U "${username}" -P "${password}" raw 0x30 0x30 0x01 0x00

if [ "${speed}" == "-1" ]; then
    ipmitool -I lanplus -H "${host}" -U "${username}" -P "${password}" raw 0x30 0x30 0x01 0x01
else
    speed_16=$(printf '%x\n' ${speed})
    ipmitool -I lanplus -H "${host}" -U "${username}" -P "${password}" raw 0x30 0x30 0x02 0xff 0x"${speed_16}"
fi
