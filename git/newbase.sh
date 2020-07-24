#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    newbase.sh TOPBRANCH BASEBRANCHS...
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi
TOPBRANCH=$1
shift 1
BASEBRANCHS=$@
NEWBRANCH=${TOPBRANCH}
for BASEBRANCH in ${BASEBRANCHS};do
NEWBRANCH=${NEWBRANCH}_${BASEBRANCH}
done
git checkout ${TOPBRANCH}
git checkout -b ${NEWBRANCH}
for BASEBRANCH in ${BASEBRANCHS};do
git rebase ${BASEBRANCH}
done
