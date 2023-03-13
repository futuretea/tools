#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    registry-clean pattern aliasname localhost

    registry-clean head dockerhub 192.168.5.79:5100
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
    exit 1
fi

pattern=$1
aliasname=$2
localhost=$3


docker stop ${aliasname}_mirror_1
regctl registry set --tls disabled ${localhost}
fd ${pattern} /cache/${aliasname} | awk -F "/" '{print "regctl tag delete '"${localhost}"'/"$9"/"$10":"$13}' | bash
docker exec ${aliasname}_local_1 /bin/registry garbage-collect /etc/docker/registry/config.yml -m
docker start ${aliasname}_mirror_1
