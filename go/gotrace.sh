#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    new HTTP SECOND
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

HTTP=$1
SECOND=$2

echo "[Fetching trace.data]"
curl http://${HTTP}/debug/pprof/trace?seconds=${SECOND} --no-progress-meter -o trace.data
echo "[Analyzing trace.data]"
go tool trace trace.data
