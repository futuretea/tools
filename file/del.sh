#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    del.sh FILES
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

FILES=$@
RECYCLE=$HOME/.recycle
NOW=$(date +%Y-%m-%d-%H:%M:%S)
mkdir -p $RECYCLE
for FILE in $FILES;do
    FULL=$(readlink -f $FILE)
    NAME=$(basename $FULL)
    FULL64=$(echo $FULL | base64)
    TARGET="$RECYCLE/$FULL64/$NOW"
    mkdir -p $TARGET
    mv $FILE $TARGET/$NAME
done
