#!/bin/bash
set -e

usage() {
    echo "usage:"
    echo "  gox.sh CODEPATH"
}

if [ $# -lt 1 ]; then
    usage
    exit
fi

CODEPATH=$1
shift 1
codemod -m -d "${CODEPATH}" --extensions go $@
