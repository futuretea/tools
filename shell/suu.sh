#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
# set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    suu.sh NAME
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

NAME=$1
if grep -E "^${NAME}\s.*$" /etc/sudoers; then
    sed -i "s/^${NAME}.*$/${NAME} ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
else
cat >/etc/sudoers <<EOF
root    ALL=(ALL:ALL) ALL
${NAME} ALL=(ALL) NOPASSWD: ALL
EOF
fi
echo "##################"
cat /etc/sudoers
echo "##################"

gpasswd -a "${NAME}" docker
