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
all: lint test run
.PHONY: lint test run
run:
	go run main.go
build:
	go build
lint:
	golangci-lint run
test:
	go test demo -run Testdemo
bench:
	go test -benchmem -bench Benchmark_demo
EOF
cat > "${DEMODIR}"/main.go <<EOF
package main
import (
	"fmt"
)

func demo() string {
	return "hello world"
}

func main(){
  fmt.Println(demo())
}
EOF
cat > "${DEMODIR}"/main_test.go <<EOF
package main

import (
	"testing"
)

func Test_demo(t *testing.T){
  result := demo()
  if result == "hello world" {
    t.Log(result)
  }
}

func Benchmark_demo(b *testing.B){
  result := demo()
  if result == "hello world" {
    b.Log(result)
  }
}
EOF
make
code .
