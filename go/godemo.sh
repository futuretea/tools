#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    new
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 0 ];then
    useage
    exit 1
fi

DEMODIR=$(mktemp -d)
echo "${DEMODIR}"
cd "${DEMODIR}"
go mod init demo
cat > "${DEMODIR}"/Makefile <<EOF
all: run
.PHONY: run lint test
run:
	go run main.go
build:
	go build
lint:
	golangci-lint run -v
test:
	go test
EOF
cat > "${DEMODIR}"/main.go <<EOF
package main
import (
	"fmt"
)
func main(){
	fmt.Println("hello world")
}
EOF
make
code .
