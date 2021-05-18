#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    init_rclocal.sh
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

if [ x"root" != x"$USER" ]; then
    exit_err "user must be root"
fi

cat >/usr/lib/systemd/system/rc-local.service <<EOF
[Unit]
Description="/etc/rc.local Compatibility"

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardInput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/rc.local <<EOF
#!/usr/bin/env bash
[[ -n \$DEBUG ]] && set -x
set -eou pipefail
if [ -d /etc/rc.local.d ]; then
    for rcscript in /etc/rc.local.d/*.sh; do
        if [ -r "\${rcscript}" ];then
            sh "\${rcscript}"
        fi
    done
fi
EOF
chmod +x /etc/rc.local
mkdir -p /etc/rc.local.d
systemctl enable rc-local
