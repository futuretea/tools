#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    load.sh SCRIPTPATH
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
    exit
fi

SCRIPTPATH=$1
INSTALLPATH="/usr/local/bin/tools"

install() {
    local SCRIPTFILE=$1
    local BINNAME
    local INSTALLBIN
    BINNAME="$(basename "${SCRIPTFILE}")"
    INSTALLBIN="${INSTALLPATH}/${BINNAME%.*}"
    sudo cp "${SCRIPTFILE}" "${INSTALLBIN}"
    sudo chmod +x "${INSTALLBIN}"
    echo "${INSTALLBIN}"
}

mkdir -p "${INSTALLPATH}"
if [ -d "${SCRIPTPATH}" ]; then
    find "${SCRIPTPATH}" -regex ".*\.sh" | while read -r SCRIPTFILE; do
        install "${SCRIPTFILE}"
    done
    find "${SCRIPTPATH}" -regex ".*\.py" | while read -r PYTHONILE; do
        install "${PYTHONILE}"
    done
else
    if [ -f "${SCRIPTPATH}" ]; then
        install "${SCRIPTPATH}"
    fi
fi

ls "${INSTALLPATH}"
