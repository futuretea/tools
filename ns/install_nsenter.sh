#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    install_nsenter.sh [NSENTER_VERSION]
EOF
}

exit_err() {
    echo >&2 "$1"
    exit 1
}

NSENTER_VERSION=${1:-"2.34"}
cd "$(mktemp -d)"
curl -fsSLO "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${NSENTER_VERSION}/util-linux-${NSENTER_VERSION}.tar.gz"
tar -zxf util-linux-${NSENTER_VERSION}.tar.gz
cd util-linux-${NSENTER_VERSION}
./configure --without-ncurses
make nsenter
sudo cp nsenter /usr/local/bin
cd ..
rm -rf util-linux-${NSENTER_VERSION}
