#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    install_krew.sh 
EOF
}

exit_err() {
   echo >&2 $1
   exit 1
}
if [ $# -lt 0 ];then
    useage
    exit 1
fi

cd $(mktemp -d)
proxychains curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.3.0/krew.{tar.gz,yaml}"
tar zxvf krew.tar.gz
./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install --manifest=krew.yaml --archive=krew.tar.gz

