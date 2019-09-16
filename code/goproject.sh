#!/usr/bin/env bash

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
grep --exclude-dir=vendor --include="*.go" -Por "(?<=^package\s).*$"
echo ""

echo "import:"
grep --exclude-dir=vendor --include="*.go" -Porz "(?<=import\s)\(([^()]|(?R))*(?=\))"
echo ""

echo "var:"
grep --exclude-dir=vendor --include="*.go" -Por "^var\s.*"
echo ""

echo "type:"
grep --exclude-dir=vendor --include="*.go" -Por "^type\s.*"
echo ""

#echo "字符串："
#grep --exclude-dir=vendor --include="*.go" -Por "\"[^\"]+\""
#echo ""

echo "构建目标:"
grep --exclude-dir=vendor --include="Makefile*" -Por "^\S*(?=:)"
echo ""

echo "入口文件："
find . -type f -name "main.go" -not -path "./vendor/*"
echo ""

echo "SHELL脚本:"
find . -type f -name "*.sh" -not -path "./vendor/*"
echo ""

echo "Dockerfile:"
find . -type f -name "Dockerfile*" -not -path "./vendor/*"
echo ""

echo "images:"
grep --exclude-dir=vendor --include="Dockerfile*" -Por "(?<=FROM\s).*$"
echo ""

echo "Markdown:"
find . -type f -name "*.md" -not -path "./vendor/*"
cd -
