#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    newdesk.sh NAME EXEC [VERSION]
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

NAME=$1
EXEC=$2
VERSION=${3:-"1.0"}

if [ x"root" != x"$USER" ]; then
    exit_err "user must be root"
fi

cat >/usr/share/applications/"${NAME}".desktop <<EOF
[Desktop Entry]
Type=Application
Version=${VERSION}
Name=${NAME}
Exec=${EXEC}
TryExec=${EXEC}
Terminal=false
EOF

