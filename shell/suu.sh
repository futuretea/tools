#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
# set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    suu.sh NAME
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 1 ];then
    useage
    exit
fi

NAME=$1
if grep -E "^${NAME}\s.*$" /etc/sudoers; then
sed -i "s/^${NAME}.*$/${NAME} ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
else
cat >>/etc/sudoers <<EOF
${NAME} ALL=(ALL) NOPASSWD: ALL
EOF
fi

gpasswd -a "${NAME}" docker
