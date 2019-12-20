#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    download_m3u8.sh CONFIGFILE DIR
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi
CONFIGFILE=$1
DIR=$2
mkdir -p "${DIR}"
while read -r line;do
arr=($line)
sub="${DIR}/${arr[0]}"
if [ ! -f "${sub}/main.ts" ];then
m3u8 -u="${arr[1]}" -o="${sub}"
fi
done < "${CONFIGFILE}"