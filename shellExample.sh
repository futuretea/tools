#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  shellExample.sh scriptpath scriptargs..."
}

if [ $# -lt 1 ];then
    useage
    exit
fi

SCRIPTPATH=$1
SCRIPTNAME=$(basename "${SCRIPTPATH}")
shift 1
SCRIPTARGS=$@
SCRIPTARGNUM=$#
cat > "${SCRIPTPATH}" <<EOF
#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  ${SCRIPTNAME} ${SCRIPTARGS}"
}

if [ \$# -lt ${SCRIPTARGNUM} ];then
    useage
    exit
fi

EOF

i=1
for ARG in ${SCRIPTARGS};do
cat >> "${SCRIPTNAME}" <<EOF
${ARG}=\$$i
EOF
let i++
done