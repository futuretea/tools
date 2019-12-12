#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
    cat <<"EOF"
USAGE:
    wtf.sh SOMETHING
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

urlEncode() {
    echo |tr -d '\n'|od -An -tx1|tr ' ' %
}

SOMETHING=$(echo "$@"|tr -d '\n'|od -An -tx1|tr ' ' %)
open "https://www.google.com/search?q=${SOMETHING}"
open "https://www.baidu.com/s?wd=${SOMETHING}"
open "https://github.com/search?q=${SOMETHING}"
open "https://stackoverflow.com/search?q=${SOMETHING}"
open "https://medium.com/search?q=${SOMETHING}"
open "http://s.weibo.com/weibo/${SOMETHING}"
open "https://weixin.sogou.com/weixin?type=2&query=${SOMETHING}"
open "https://www.youtube.com/results?search_query=${SOMETHING}"
open "https://search.bilibili.com/all?keyword=${SOMETHING}"
