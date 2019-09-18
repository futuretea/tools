#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  goapi.sh SRCPATH"
}

if [ $# -lt 1 ];then
    useage
    exit
fi

SRCPATH=$1
if [ ! -d "${SRCPATH}" ];then
    echo "${SRCPATH} is not a dir"
    exit
fi
cd "${SRCPATH}"

red='\033[0;31m'
plain='\033[0m'
packages=(
fmt
bytes
strings
strconv
regexp
encoding
base64
unicode
pem
json
yaml
crypto
pkix
x509
uuid
io
ioutil
template
time
os
exec
cron
path
filepath
runtime
debug
reflect
sort
errors
log
logs
gorm
xorm
orm
flag
pflag
viper
beego
gin
grpc
net
http
httplib
httptest
testing
sync
context
consul
etcd
db
mgo
bson
redis
zip
jwt
"[a-z]*v[0-9]"
)

gos(){
    local package=$1
    local result
    result=$(grep --exclude-dir=vendor --include="*.go" -nPr "\s${package}\.[A-Z].*" || echo -n "")
    if [ x"${result}" != "x" ];then
        echo -ne "${red}${package}${plain}:\n${result}\n"
    fi
}

for ((i=1;i<=${#packages[@]};i++ )); do
    package="${packages[$i-1]}"
    gos "${package}"
done

cd -

