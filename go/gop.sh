#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

useage() {
    cat <<"EOF"
USAGE:
    gop.sh SRCPATH
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -ne 1 ]; then
    useage
    exit
fi

SRCPATH=$1
if [ ! -d "${SRCPATH}" ]; then
    echo "${SRCPATH} is not a dir"
    exit
fi

cd "${SRCPATH}" || return

red='\033[0;31m'
plain='\033[0m'

info() {
    echo -ne "\n${red}$1：${plain}\n"
}

filenovendor() {
    find . -type f -name "$1" -not -path "./vendor/*"
}

grepnovendor() {
    grep --exclude-dir=vendor --include="$1" -Por "$2"
}

grepnovendorz() {
    grep --exclude-dir=vendor --include="$1" -Porz "$2"
}

info "仓库统计"
git shortlog --numbered --summary .

info "目录结构"
tree -d -I vendor

info "导入的包"
grepnovendorz "*.go" "(?<=import\s)\(([^()]|(?R))*(?=\))"

info "定义的包"
grepnovendor "*.go" "(?<=^package\s).*$"

info "注解信息"
grepnovendor "*.go" "^//\s*\@.*$"

# info "注释信息"
# grepnovendor "*.go" "^//\s*[^\@]*$"

info "路径信息"
grepnovendor "*.go" '\"/[^(\|\/")]+/*[^(\")]*\"'

info "main.go"
filenovendor "main.go"

info "json"
filenovendor "*.json"

info "xml"
filenovendor "*.xml"

info "proto"
filenovendor "*.proto"

info "sql"
filenovendor "*.sql"

info "命令脚本"
filenovendor "*.sh"

info "构建文件"
filenovendor "Makefile*"

info "构建目标"
grepnovendor "Makefile*" "^\S*(?=:)"

info "容器构建"
filenovendor "Dockerfile*"

info "基础容器"
grepnovendor "Dockerfile*" "(?<=FROM\s).*$"

info "容器镜像"
grepnovendor "*.yaml" "(?<=image:\s).*$"
grepnovendor "*.yml" "(?<=image:\s).*$"

info "yml"
filenovendor "*.yml"

info "yaml"
filenovendor "*.yaml"

info "markdown"
filenovendor "*.md"

cd - || return
