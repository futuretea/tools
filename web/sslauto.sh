#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    sslauto.sh WEBROOT EMAIL DOMAIN [SUBS...]
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    useage
    exit 1
fi

WEBROOT=$1
EMAIL=$2
DOMAIN=$3
shift 3
SUBS=$@
ARGS="--webroot -w ${WEBROOT} --email ${EMAIL} -d ${DOMAIN}"
for SUB in $SUBS;do
	ARGS="$ARGS -d ${SUB}.${DOMAIN}"
done
sudo certbot certonly ${ARGS}
sudo openresty -s reload
