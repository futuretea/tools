#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    nssh.sh
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

red='\033[0;31m'
plain='\033[0m'

info() {
    echo -ne "\n${red}$1：${plain}\n"
}

show_resources() {
    info "List droplet"
    doctl compute droplet list

    info "List snapshot"
    doctl compute snapshot list
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

# Select
info "Select region"
REGION=$(doctl compute region list --no-header --format Slug | fzf)
echo "  Region slug is ${REGION}"

# Get
info "Get droplet"
DOID=$(doctl compute droplet list --no-header --format ID)
if [ -z "${DOID}" ]; then
    echo "  Droplet isn't exist"
    info "Select image"
    IMAGE=$(doctl compute image list --public --no-header --format Slug | fzf)
    info "create new droplet use ${IMAGE} in ${REGION}"
    doctl compute droplet create --image "${IMAGE}" --region "${REGION}" --size "s-1vcpu-1gb" "do-default" --wait
    show_resources
    exit 0
else
    echo "  Droplet id is ${DOID}"
fi

# Shutdown
info "Shutdown droplet"
doctl compute droplet-action power-off "${DOID}" --wait

# Snapshot
SSID=$(doctl compute snapshot list --no-header --format ID)
if [ -z "${SSID}" ]; then
    echo "  Snapshot isn't exist"
    info "Create snapshot"
    doctl compute droplet-action snapshot "${DOID}" --wait --snapshot-name SS
    SSID=$(doctl compute snapshot list --no-header --format ID)
fi
echo "  Snapshot id is ${SSID}"

# Transfer
SSREGION=$(doctl compute droplet list --no-header --format Region)
echo "  Snapshot region is ${SSREGION}"
if [ x"${SSREGION}" != x"${REGION}" ]; then
    info "Start transfer snapshot ${SSID} to ${REGION}"
    doctl compute image-action transfer "${SSID}" --region "${REGION}" --wait
fi

# New
info "Create new droplet use snapshot ${SSID} in ${REGION}"
doctl compute droplet create --image "${SSID}" --region "${REGION}" --size "s-1vcpu-1gb" "do-${SSID}" --wait
info "Get ip from new droplet"
NEWIP=$(doctl compute droplet list --no-header --format PublicIPv4 | awk 'END {print}')
echo "  new droplet ip is ${NEWIP}"

echo "Wait for IP is up"
sleep 60
if ping -c 1 -i 0.3 -W 1 "${NEWIP}" &>/dev/null; then
    echo "IP is accessible."
    # Clean
    info "Clean snapshot"
    doctl compute snapshot delete "${SSID}" -f
    info "Clean droplet"
    doctl compute droplet delete "${DOID}" -f
else
    echo "IP is unaccessible."
    NEWDOID=$(doctl compute droplet list --no-header --format ID | awk 'END {print}')
    doctl compute droplet delete "${NEWDOID}" -f
fi
