#!/bin/bash
useage(){
    echo "useage:"
    echo "  suu.sh NAME"
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
