#!/usr/bin/env bash

useage(){
    echo "useage:"
    echo "  gop.sh srcpath"
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SRCPATH=$1
if [ ! -d  "${SRCPATH}" ];then
    echo "${SRCPATH} is not a dir"
    exit
fi

cd "${SRCPATH}" || return

red='\033[0;31m'
plain='\033[0m'

info(){
    echo -ne "\n${red}$1：${plain}\n"
}

filenovendor(){
    find . -type f -name \"$1\" -not -path "./vendor/*"
}

grepnovendor(){
    grep --exclude-dir=vendor --include=$1 -Por $2
}

grepnovendorz(){
    grep --exclude-dir=vendor --include=$1 -Porz $2
}

info "仓库统计"
git shortlog --numbered --summary .

info "目录结构"
tree -d -I vendor

info "导入的包"
grepnovendorz "*.go" "(?<=import\s)\(([^()]|(?R))*(?=\))"

info "定义的包"
grepnovendor "*.go" "(?<=^package\s).*$"

info "构建目标"
grepnovendor "Makefile*" "^\S*(?=:)"

info "入口文件"
filenovendor "main.go"

info "命令脚本"
filenovendor "*.sh"

info "容器脚本"
filenovendor "Dockerfile*"

info "容器镜像"
grepnovendor "Dockerfile*"  "(?<=FROM\s).*$"

info "相关文档"
filenovendor "*.md"

cd - || return
