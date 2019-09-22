#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
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

info(){
    echo -ne "\n${red}$1：${plain}\n"
}

show_resources(){
  info "List droplet"
  doctl compute droplet list

  info "List snapshot"
  doctl compute snapshot list
}

if [ $# -lt 0 ];then
    useage
    exit 1
fi

info "Select region"
REGION=$(doctl compute region list --no-header --format Slug | fzf)
echo "  Region slug is ${REGION}"

info "Get droplet"
DOID=$(doctl compute droplet list --no-header --format ID)


if [ -z "${DOID}" ];then
echo "  Droplet isn't exist"
info "Select image"
IMAGE=$(doctl compute image list --public  --no-header --format Slug | fzf)
info "create new droplet use ${IMAGE} in ${REGION}"
doctl compute droplet create --image "${IMAGE}" --region "${REGION}" --size "s-1vcpu-1gb" "do-default" --wait
show_resources
exit 0
else
echo "  Droplet id is ${DOID}"
fi

info "Shutdown droplet"
doctl compute droplet-action power-off "${DOID}" --wait

info "Create snapshot"
doctl compute droplet-action snapshot "${DOID}" --wait --snapshot-name SS
SSID=$(doctl compute snapshot list --no-header --format ID)
echo "  Snapshot id is ${SSID}"

info "Start transfer snapshot ${SSID} to ${REGION}"
doctl compute image-action transfer "${SSID}" --region "${REGION}" --wait

info "create new droplet use ${SSID} in ${REGION}"
doctl compute droplet create --image "${SSID}" --region "${REGION}" --size "s-1vcpu-1gb" "do-${SSID}" --wait

info "Get ip from new droplet"
NEWIP=$(doctl compute droplet get --no-header --format IP)
echo "  new droplet ip is ${NEWIP}"

info "Clean snapshot"
doctl compute snapshot delete "${SSID}" -f

info "Clean droplet"
doctl compute droplet delete "${DOID}" -f

show_resources