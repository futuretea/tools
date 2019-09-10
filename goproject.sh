#!/usr/bin/env bash
set -e

useage(){
    echo "useage:"
    echo "  goproject.sh srcpath"
}

if [ $# -ne 1 ];then
    useage
    exit
fi

SRCPATH=$1
cd ${SRCPATH}

echo "git统计："
git shortlog --numbered --summary .

echo "目录结构："
tree -d -I vendor
echo ""

echo "packages:"
grep --exclude-dir=vendor --include="*.go" -r "package " | awk '{print $2,$1}' | sort -u
echo ""

echo "构建目标:"
grep --exclude-dir=vendor --include="Makefile" -r -oE "^[a-z]\S*:"
echo ""

echo "入口文件："
find . -type f -name "main.go" -not -path "./vendor/*"
echo ""

echo "SHELL脚本:"
find . -type f -name "*.sh" -not -path "./vendor/*"
echo ""

echo "Dockerfile:"
find . -type f -name "*Dockerfile*" -not -path "./vendor/*"
echo ""

echo "images:"
grep --exclude-dir=vendor --include="*Dockerfile*" -r "FROM " | awk '{print $2,$1}' | sort -u
echo ""

echo "README:"
cat README.md
cd -