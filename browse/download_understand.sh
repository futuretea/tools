#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    download_understand.sh MAJOR MINOR PATCH
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

MAJOR=$1
MINOR=$2
PATCH=$3
proxychains wget "http://builds.scitools.com/all_builds/b${PATCH}/Understand/Understand-${MAJOR}.${MINOR}.${PATCH}-Linux-64bit.tgz"

