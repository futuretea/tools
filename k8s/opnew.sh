#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  opnew REPO PROJECT GROUP VERSION KIND"
}

if [ $# -ne 5 ];then
    useage
    exit
fi

REPO=$1
PROJECT=$2
GROUP=$3
VERSION=$4
KIND=$5

export GO111MODULE=on
export GOPROXY=https://goproxy.io
operator-sdk new "${PROJECT}" --repo "${REPO}/${PROJECT}"
cd "${PROJECT}"
operator-sdk add api --api-version="${GROUP}/${VERSION}" --kind="${KIND}"
operator-sdk add controller --api-version="${GROUP}/${VERSION}" --kind="${KIND}"
go mod vendor
