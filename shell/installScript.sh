#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  installScript.sh SCRIPTPATH"
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SCRIPTPATH=$1

install(){
    local SCRIPTFILE=$1
    local BINNAME
    BINNAME=$(basename "${SCRIPTFILE}")
    local INSTALLBIN="/usr/local/bin/${BINNAME%.*}"
    sudo cp "${SCRIPTFILE}" "${INSTALLBIN}"
    sudo chmod +x "${INSTALLBIN}"
    echo "${INSTALLBIN}"
}

if [ -d "${SCRIPTPATH}" ];then
    find "${SCRIPTPATH}" -name "*.sh" | while read -r SCRIPTFILE;do
        install "${SCRIPTFILE}"
    done
else
    if [ -f "${SCRIPTPATH}" ];then
        install "${SCRIPTPATH}"
    fi
fi
