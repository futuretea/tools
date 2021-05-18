#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    install_jcli.sh
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
wget https://github.com/jenkins-zh/jenkins-cli/releases/latest/download/jcli-linux-amd64.tar.gz
tar -zxvf jcli-linux-amd64.tar.gz
sudo mv jcli /usr/local/bin/
cd -
rm -r "${TEMPDIR}"
