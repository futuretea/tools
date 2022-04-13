#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    install_ws_nginx.sh DOMAIN UUID INSTALL CERTBOT
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
INSTALL=$3
CERTBOT=$4

if [ $INSTALL == "true" ];then
  yum -y install epel-release
  yum -y install certbot
  cat >/etc/yum.repos.d/nginx.repo <<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
  yum -y install nginx
fi

# cert nginx
cat >/etc/nginx/conf.d/acme-challenge.conf <<EOF
server {
    listen       80;
    server_name  ${DOMAIN};
    location / {
        add_header Strict-Transport-Security max-age=15768000;
        return 301 https://\$http_host\$request_uri;
    }
    location /.well-known/acme-challenge {
       root /root;
    }
}
EOF

if [ $CERTBOT == "true" ];then
    rm -f /etc/nginx/conf.d/v2ray.conf
    systemctl enable --now nginx
    systemctl restart nginx
    certbot certonly --manual
fi

# v2ray nginx
cat >/etc/nginx/conf.d/v2ray.conf <<EOF
server {
    listen       443 http2 ssl;
    server_name  ${DOMAIN};
    charset utf-8;

    ssl_certificate    /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key    /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        add_header Content-Type 'text/html; charset=utf-8';
        return 200 "ok";
    }
    location /www {
        proxy_pass       http://${IP}:10000;
        proxy_redirect             off;
        proxy_http_version         1.1;
        proxy_set_header Upgrade   \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host      \$host;
    }
    location /html {
        proxy_pass       http://${IP}:20000;
        proxy_redirect             off;
        proxy_http_version         1.1;
        proxy_set_header Upgrade   \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host      \$host;
    }
}
EOF

systemctl enable --now nginx
systemctl restart nginx

# v2ray server
cp /etc/v2ray/config.json /etc/v2ray/config.jsonbak
cat > /etc/v2ray/config.json <<EOF
{
    "inbounds": [
        {
            "port": 10000,
            "listen": "${IP}",
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
                    "path": "/www",
                    "headers": {}
                },
                "tlsSettings": {
                    "allowInsecure": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "serverName": "$DOMAIN",
                    "allowInsecureCiphers": false
                },
                "security": "none",
                "network": "ws",
                "sockopt": {}
            }
        },
        {
            "port": 20000,
            "listen": "${IP}",
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
                    "path": "/html",
                    "headers": {}
                },
                "tlsSettings": {
                    "allowInsecure": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "serverName": "$DOMAIN",
                    "allowInsecureCiphers": false
                },
                "security": "none",
                "network": "ws",
                "sockopt": {}
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        },
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
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
systemctl enable --now v2ray
systemctl restart v2ray

# status
systemctl status nginx
systemctl status v2ray
