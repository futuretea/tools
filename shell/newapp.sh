#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    newapp.sh NAME URL [OPTION]
    eg:
      newapp.sh wechat https://wx2.qq.com
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 2 ];then
    useage
    exit 1
fi

NAME=$1
URL=$2
shift 2
OPTION=$@

mkdir -p /usr/local/bin/app
cd /usr/local/bin/app
nativefier --name "${NAME}" "${URL}" "${OPTION}"
cat > /usr/share/applications/"${NAME}".desktop << EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=${NAME}
Exec=/usr/local/bin/app/${NAME}-linux-x64/${NAME}
TryExec=/usr/local/bin/app/${NAME}-linux-x64/${NAME}
Terminal=false
EOF

