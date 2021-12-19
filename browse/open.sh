#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
# set -e
set -ou pipefail

usage() {
    cat <<"EOF"
USAGE:
    open.sh OPENPATH
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit
fi

OPENPATH=$1
WINBROWSER=msedge
if [ -f "${OPENPATH}" ]; then
    type wsl.exe >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        while read -r LINE; do
            cmd.exe /c "start ${WINBROWSER} ${LINE}"
        done <"${OPENPATH}"
    else
        while read -r LINE; do
            xdg-open "$LINE" >/dev/null 2>&1
        done <"${OPENPATH}"
    fi
else
    type wsl.exe >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        cmd.exe /c "start ${WINBROWSER} ${OPENPATH}"
    else
        xdg-open "${OPENPATH}" >/dev/null 2>&1
    fi
fi
