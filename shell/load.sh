#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    load.sh SCRIPTPATH
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SCRIPTPATH=$1
INSTALLPATH="/usr/local/bin/tools"

install(){
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
if [ -d "${SCRIPTPATH}" ];then
    find "${SCRIPTPATH}" -regex ".*\.\(py\|sh\)" | while read -r SCRIPTFILE;do
        install "${SCRIPTFILE}"
    done
else
    if [ -f "${SCRIPTPATH}" ];then
        install "${SCRIPTPATH}"
    fi
fi

ls "${INSTALLPATH}"