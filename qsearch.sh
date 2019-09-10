#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  qsearch.sh SOMETHING"
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SOMETHING=$1
open "https://www.google.com/search?q=${SOMETHING}"
open "https://www.baidu.com/s?wd=${SOMETHING}"
open "https://github.com/search?q=${SOMETHING}"
open "http://s.weibo.com/weibo/${SOMETHING}"
open "https://weixin.sogou.com/weixin?type=2&query=${SOMETHING}"
open "https://www.youtube.com/results?search_query=${SOMETHING}"