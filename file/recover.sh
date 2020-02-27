#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    recover.sh FILE
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    useage
    exit 1
fi

FILE=$1
RECYCLE=$HOME/.recycle
FULL=$(readlink -f "$FILE")
FULL64=$(echo "$FULL" | base64)
if [ ! -d $RECYCLE/$FULL64 ];then
    exit_err "backup isn't exist!"
fi
TIME=$(ls $RECYCLE/$FULL64 | fzf)
NAME=$(basename $FULL)
TARGET=$RECYCLE/$FULL64/$TIME/$NAME
mv $TARGET $FULL
