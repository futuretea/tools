#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  goa.sh SRCPATH"
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
yaml
json
jsonpath
proto
toml
bson
zip
btree
crypto
pkix
x509
uuid
jwt
oauth2
spec
validator
io
ioutil
template
time
timeconv
os
exec
cron
path
filepath
unix
windows
runtime
debug
reflect
reflect2
sort
errors
log
logs
gorm
xorm
orm
flag
pflag
cobra
cmd
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
simplelru
nats
consul
etcd
db
database
mgo
redis
"[a-z]*v[0-9][a-z]*[0-9]*"
kubernetes
k8s
kube
kubectl
helm
helm2
helm3
docker
rest
cert
auth
constants
config
conf
cfg
version
websocket
models
routers
controllers
utils
tools
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

