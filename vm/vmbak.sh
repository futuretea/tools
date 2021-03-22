#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    vmbak.sh src dst
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

src=${1:-"/var/lib/libvirt/images/"}
dst=${2:-"/var/lib/libvirt/images/"}
echo "==> halt"
sudo vagrant halt
echo "==> list"
vms=$(sudo vagrant status --machine-readable | grep metadata | awk -F ',' '{print $2}')
echo "$vms"
local_dir=$(basename $(pwd))
blank=$(mktemp)
echo "${vms}" | while read -r vm;do
echo "==> backup $vm"
img=${local_dir}_${vm}.img
if [ -f ${src}${img} ]; then
sudo  rsync -avPr --progress --delete ${src}${img} ${dst}${img}.bak
fi
done
echo "==> up"
sudo vagrant up
