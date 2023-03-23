#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    rsync-artifacts.sh SOURCE TARGET
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

SOURCE=$1
TARGET=$2
artifact_suffixs=(
"amd64.iso"
"initrd-amd64"
"vmlinuz-amd64"
"rootfs-amd64.squashfs"
)
for ((i = 1; i <= ${#artifact_suffixs[@]}; i++)); do
  artifact_suffix=${artifact_suffixs[$i-1]}
  artifact_source_name=${SOURCE}/harvester-master-${artifact_suffix}
  artifact_target_name=${TARGET}/harvester-${artifact_suffix}
  rsync -vP ${artifact_source_name} ${artifact_target_name}
done
popd
