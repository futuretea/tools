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

echo "==> halt"
sudo vagrant halt
echo "==> list"
vms=$(sudo vagrant status --machine-readable | grep metadata | awk -F ',' '{print $2}')
echo "$vms"
local_dir=$(basename $(pwd))
cd /var/lib/libvirt/images/
blank=$(mktemp)
echo "${vms}" | while read -r vm;do
echo "==> restore $vm"
img=${local_dir}_${vm}.img
sudo rsync -a --delete-before --progress --stats ${img}{.bak,}
done
cd -
echo "==> up"
sudo vagrant up
