#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
    cat <<"EOF"
USAGE:
    fq.sh APP(sh git go docker) ACTION(+ -) [URL]
EOF
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ];then
    useage
    exit
fi

APP=$1
ACTION=$2
URL=${3:-"http://127.0.0.1:12333"}

sh_set(){
    echo export http_proxy="${URL}"
    echo export https_proxy="${URL}"
}

sh_unset(){
    echo unset http_proxy
    echo unset https_proxy
}

git_set(){
    git config --global http.proxy "${URL}"
    git config --global https.proxy "${URL}"
}

git_unset(){
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}

docker_set(){
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${URL}"
EOF
cat <<EOF >/etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=${URL}"
EOF
systemctl daemon-reload
systemctl restart docker
systemctl show --property=Environment docker
}

docker_unset(){
    rm -rf /etc/systemd/system/docker.service.d
    systemctl daemon-reload
    systemctl restart docker
    systemctl show --property=Environment docker
}
if [ "x${APP}" == "xgo" ];then
    if [ "x${ACTION}" == "x+"  ];then
        git_set
        sh_set
    elif [ "x${ACTION}" == "x-"  ];then
        git_unset
        sh_unset
    else
        exit_err "unknown action ${ACTION}"
    fi
elif [ "x${APP}" == "xgit" ];then
    if [ "x${ACTION}" == "x+"  ];then
        git_set
    elif [ "x${ACTION}" == "x-"  ];then
        git_unset
    else
        exit_err "unknown action ${ACTION}"
    fi
elif [ "x${APP}" == "xsh" ];then
    if [ "x${ACTION}" == "x+"  ];then
        sh_set
    elif [ "x${ACTION}" == "x-"  ];then
        sh_unset
    else
        exit_err "unknown action ${ACTION}"
    fi
elif [ "x${APP}" == "xdocker" ];then
    if [ "x${ACTION}" == "x+"  ];then
        docker_set
    elif [ "x${ACTION}" == "x-"  ];then
        docker_unset
    else
        exit_err "unknown action ${ACTION}"
    fi
else
    exit_err "unknown app ${APP}"
fi
