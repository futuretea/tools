#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<"EOF"
USAGE:
    install_kubectl-fzf.sh VERSION
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

REPO="bonnefoa/kubectl-fzf"
VERSION=${1:-$(releasef ${REPO})}
TARBAR="kubectl-fzf_linux_amd64.tar.gz"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${TARBAR}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
echo ${PWD}
curl -fsSLO "${URL}"
tar -zxvf "${TARBAR}"
sudo mv cache_builder /usr/local/bin/
sudo mv kubectl_fzf.plugin.zsh ${HOME}/.kubectl_fzf.plugin.zsh
cd -
rm -r "${TEMPDIR}"
