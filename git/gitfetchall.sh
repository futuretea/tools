#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -ou pipefail

useage() {
    cat <<HELP
USAGE:
    gitfetchall.sh 
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all
