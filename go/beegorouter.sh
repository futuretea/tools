#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    beegorouter.sh IN OUT
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -gt 2 ]; then
    usage
    exit 1
fi

IN=${1:-"router.go"}
OUT=${2:-"router.dot"}
cat > "$OUT" <<EOF
digraph router {
    rankdir=LR
    node [shape="record"];
    edge [style="dashed"];
EOF
grep -E "beego\..*Router" "$IN" | grep -o "(.*)" | sed "s/[\(\)\",]/ /g" |  awk '{gsub(/:/," ",$3);print $0}' | awk '{printf "\t\"%s[%s]\" -> \"%s::%s\" -> \"%s\";\n",$1,$3,$2,$4,$2}' >> "$OUT"
cat >> "$OUT" <<EOF
}
EOF
