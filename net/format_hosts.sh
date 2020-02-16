#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    format_hosts.sh
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

file_name=/etc/hosts
#清除注释跟空格
sudo sed -ri '/^#/d;/^$/d;' "$file_name"

#取出host下的所有IP
sudo cat "$file_name" | awk '{print $1}' | sort -u > /tmp/ip

#循环进行调整
for i in $(cat /tmp/ip)
do
    sudo sed -ri '/'${i}'/{H;d;};$G' "$file_name"
done

#格式化多个空格跟tab，替换成1个空格
sudo sed -ri 's/[ \t]+/ /g' $file_name

rm /tmp/ip

