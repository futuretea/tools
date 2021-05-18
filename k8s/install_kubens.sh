#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    install_kubens.sh VERSION
EOF
}

exit_err() {
    echo >&2 "$1"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

VERSION=${1:-$(releasef aca/go-kubectx)}
TARBAR=go-kubectx_${VERSION}_Linux_x86_64.tar.gz
URL="https://github.com/aca/go-kubectx/releases/download/v${VERSION}/${TARBAR}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
curl -fsSLO "${URL}"
tar -zxvf "${TARBAR}"
sudo mv kubectx /usr/local/bin/
sudo mv kubens /usr/local/bin/
cd -
rm -r "${TEMPDIR}"
