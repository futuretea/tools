#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    webdemo.sh
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    usage
    exit 1
fi

DEMODIR=$(mktemp -d)
echo "${DEMODIR}"
cd "${DEMODIR}"
cat >index.html <<EOF
<html>

<body>

    <h1>My First Heading</h1>

    <p>My first paragraph.</p>

</body>

</html>
EOF
xdg-open index.html >/dev/null 2>&1
code .
