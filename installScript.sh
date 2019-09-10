#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  installScript.sh scriptfile"
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SCRIPTFILE=$1
BINNAME=$(basename "${SCRIPTFILE}")
INSTALLBIN="/usr/local/bin/${BINNAME%.*}"
sudo cp "${SCRIPTFILE}" "${INSTALLBIN}"
sudo chmod +x "${INSTALLBIN}"