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

gos(){
    echo $@:
    grep --exclude-dir=vendor --include="*.go" -nPr "\s($@)\.[A-Z].*" || echo "nothing"
    echo "";
}

gos fmt
gos bytes
gos strings
gos strconv
gos regexp
gos encoding
gos base64
gos unicode
gos pem
gos json
gos yaml
gos crypto
gos pkix
gos x509
gos uuid
gos io
gos ioutil
gos template
gos time
gos os
gos exec
gos cron
gos path
gos filepath
gos runtime
gos debug
gos reflect
gos sort
gos errors
gos log
gos logs
gos gorm
gos xorm
gos orm
gos flag
gos pflag
gos viper
gos beego
gos gin
gos grpc
gos net
gos http
gos httplib
gos httptest
gos testing
gos sync
gos context
gos consul
gos etcd
gos db
gos mgo
gos bson
gos redis
gos zip
gos jwt
gos "[a-z]*v[0-9]"
cd -

