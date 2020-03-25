#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
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
    useage
    exit 1
fi

VERSION=${1:-"1.0.12"}
TARBAR="kubectl-fzf_linux_amd64.tar.gz"
URL="https://github.com/bonnefoa/kubectl-fzf/releases/download/v${VERSION}/${TARBAR}"
TEMPDIR="$(mktemp -d)"
cd "${TEMPDIR}"
echo ${PWD}
proxychains curl -fsSLO "${URL}"
tar -zxvf "${TARBAR}"
sudo mv cache_builder /usr/local/bin/
sudo mv kubectl_fzf.plugin.zsh ${HOME}/.kubectl_fzf.plugin.zsh
cd -
rm -r "${TEMPDIR}"
