#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    vmrestore.sh
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

sudo vagrant destroy -f
vms=$(sudo vagrant status --machine-readable | grep metadata | awk -F ',' '{print $2}')
local_dir=$(basename $(pwd))
cd /var/lib/libvirt/images/
echo "${vms}" | while read -r vm;do
sudo rm -rf ${local_dir}_${vm}.img
sudo cp ${local_dir}_${vm}.img{.bak,}
done
cd -
sudo vagrant up
