#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    $(basename $0) scriptpath scriptargs...
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

SCRIPTPATH=$1
SCRIPTNAME=$(basename "${SCRIPTPATH}")
shift 1
SCRIPTARGS=$*
SCRIPTARGNUM=$#
cat >"${SCRIPTPATH}" <<EOFFF
#!/usr/bin/env bash
[[ -n \$DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    ${SCRIPTNAME} ${SCRIPTARGS}
HELP
}

exit_err() {
    echo >&2 "\${1}"
    exit 1
}

if [ \$# -lt ${SCRIPTARGNUM} ]; then
    useage
    exit 1
fi

EOFFF

i=1
for ARG in ${SCRIPTARGS}; do
    cat >>"${SCRIPTPATH}" <<EOFF
${ARG}=\$$i
EOFF
    ((i++))
done
chmod +x "${SCRIPTPATH}"
