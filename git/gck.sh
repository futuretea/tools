#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<"EOF"
USAGE:
    gck.sh 
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

TAG_NUM=$(git tag -l | wc -l)
if [ x"${TAG_NUM}" != x0 ]; then
    CHECK_POINT=$(git tag -l | fzf)
    BRANCH_LOCAL=${CHECK_POINT}
else
    CHECK_POINT=$(git branch -r | fzf)
    BRANCH_LOCAL=${CHECK_POINT/origin\//}
fi
git checkout -b "${BRANCH_LOCAL}" "${CHECK_POINT}"
