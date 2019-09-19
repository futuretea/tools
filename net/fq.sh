#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  fq.sh APP ACTION [URL]"
}

if [ $# -lt 2 ];then
    useage
    exit
fi

APP=$1
ACTION=$2
URL=${3:-"http://127.0.0.1:12333"}

shell_set(){
echo export http_proxy="${URL}"
echo export https_proxy="${URL}"
}

shell_unset(){
echo export http_proxy=""
echo export https_proxy=""
}

git_set(){
git config --global http.proxy "${URL}"
git config --global https.proxy "${URL}"
}

git_unset(){
git config --global --unset http.proxy
git config --global --unset https.proxy
}

if [ "x${APP}" == "xgit" ];then
    if [ "x${ACTION}" == "x+"  ];then
        git_set
    fi
    if [ "x${ACTION}" == "x-"  ];then
        git_unset
    fi
fi
if [ "x${APP}" == "xshell" ];then
    if [ "x${ACTION}" == "x+"  ];then
        shell_set
    fi
    if [ "x${ACTION}" == "x-"  ];then
        shell_unset
    fi
fi
