#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    kubepfx.sh
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

kubekey(){
    local FIELD=$1
    local FILE=$2
    cat ~/.kube/config  | grep "$FIELD" | awk -F ": " '{print $2}' | base64 -d > $FILE
}

mkdir -p ./crt
kubekey certificate-authority-data ./crt/ca.crt
kubekey client-certificate-data ./crt/client.crt
kubekey client-key-data ./crt/client.key
openssl pkcs12 -export -out ./crt/cert.pfx -inkey ./crt/client.key -in ./crt/client.crt -certfile ./crt/ca.crt
