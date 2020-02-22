#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    install_ws_nginx.sh DOMAIN UUID
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    useage
    exit 1
fi

DOMAIN=$1
UUID=$2

yum -y install epel-release
yum -y install certbot
certbot certonly --standalone -d $DOMAIN
cat >/etc/yum.repos.d/nginx.repo <<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
yum -y install nginx
cat >/etc/nginx/conf.d/v2ray.conf <<EOF
server {
    listen       443 ssl;
    server_name  $DOMAIN;

    ssl_certificate    /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key    /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    error_page 497  https://\$host\$request_uri;

location /ray {
    proxy_pass       http://127.0.0.1:10000;
    proxy_redirect             off;
    proxy_http_version         1.1;
    proxy_set_header Upgrade   \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host      \$http_host;
    }
}
EOF
systemctl enable nginx
systemctl restart nginx

cp /etc/v2ray/config.json /etc/v2ray/config.jsonbak
cat > /etc/v2ray/config.json <<EOF
{
    "inbounds": [{
        "port": 10000,
        "listen": "127.0.0.1",
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "$UUID",
                    "level": 1,
                    "alterId": 64
                }
            ]
        },
        "streamSettings": {
            "wsSettings": {
                "path": "",
                "headers": {}
            },
            "quicSettings": {
                "key": "key",
                "security": "none",
                "header": {
                    "type": "none"
                }
            },
            "tlsSettings": {
                "allowInsecure": false,
                "alpn": [
                    "http/1.1"
                ],
                "serverName": "$DOMAIN",
                "allowInsecureCiphers": false
            },
            "httpSettings": {
                "host": [
                    ""
                ],
                "path": ""
            },
            "kcpSettings": {
                "header": {
                    "type": "wechat-video"
                },
                "mtu": 1350,
                "congestion": false,
                "tti": 50,
                "uplinkCapacity": 5,
                "writeBufferSize": 2,
                "readBufferSize": 2,
                "downlinkCapacity": 20
            },
            "tcpSettings": {
                "header": {
                    "type": "none"
                }
            },
            "security": "tls",
            "network": "ws",
            "sockopt": {}
        }
    }],
    "outbounds": [{
        "protocol": "freedom",
        "settings": {}
    },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
    }],
    "routing": {
        "rules": [
            {
                "type": "field",
                "ip": ["geoip:private"],
                "outboundTag": "blocked"
            }
        ]
    }
}
EOF
systemctl enable v2ray
systemctl restart v2ray
systemctl status nginx
systemctl status v2ray