#!/bin/bash
set -e

useage() {
    echo "useage:"
    echo "  src.sh ALIASPATH"
}

if [ $# -ne 1 ]; then
    useage
    exit
fi

ALIASPATH=$1
INSTALLPATH=/usr/local/bin/alias

install() {
    local ALIASFILE=$1
    local ALIASNAME
    ALIASNAME=$(basename "${ALIASFILE}")
    local INSTALLALIAS="${INSTALLPATH}/${ALIASNAME}"
    sudo cp "${ALIASFILE}" "${INSTALLALIAS}"
    sudo chmod +x "${INSTALLALIAS}"
    echo "${INSTALLALIAS}"
}

mkdir -p /usr/local/bin/alias

if [ -d "${ALIASPATH}" ]; then
    find "${ALIASPATH}" -name "*.alias" | sort -u | while read -r ALIASFILE; do
        install "${ALIASFILE}"
    done
else
    if [ -f "${ALIASPATH}" ]; then
        install "${ALIASPATH}"
    fi
fi

cat >"${INSTALLPATH}/all" <<EOF
#all alias there
EOF
find "${INSTALLPATH}" -name "*.alias" | sort -u | while read -r INSTALLALIAS; do
    cat >>"${INSTALLPATH}/all" <<EOF
source "${INSTALLALIAS}"
EOF
done
echo "source ${INSTALLPATH}/all"
