#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    update_v2ray.sh
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi

source /usr/local/bin/private/v2ray.alias
if [ -f $V2RAY_CONFIG ];then
cat >$V2RAY_CONFIG <<EOF
{
  "dns": {
    "servers": [
      "8.8.8.8"
    ]
  },
  "inbounds": [
    {
      "port": 1080,
      "listen": "0.0.0.0",
      "settings": {
        "udp": false
      },
      "protocol": "socks"
    },
    {
      "port": 12333,
      "listen": "0.0.0.0",
      "protocol": "http"
    }
  ],
  "log": {
    "error": "/opt/v2ray/error.log",
    "access": "/opt/v2ray/access.log",
    "loglevel": "error"
  },
  "outbounds": [
    {
      "sendThrough": "0.0.0.0",
      "mux": {
        "enabled": true,
        "concurrency": 8
      },
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$V2RAY_IP",
            "users": [
              {
                "id": "$V2RAY_UID",
                "alterId": $V2RAY_ALERTID,
                "security": "$V2RAY_METHOD",
                "level": $V2RAY_LEVEL
              }
            ],
            "port": $V2RAY_PORT
          }
        ]
      },
      "tag": "do",
      "streamSettings": {
        "wsSettings": {
          "path": "/www",
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
          "serverName": "$V2RAY_IP",
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
    }
  ],
  "routing": {
      "name": "绕过本地和CN地址",
      "domainStrategy": "IPIfNonMatch",
      "rules": [
        {
          "type": "field",
          "outboundTag": "direct",
          "domain": [
            "localhost",
            "geosite:cn"
          ]
        },
        {
          "type": "field",
          "outboundTag": "direct",
          "ip": [
            "geoip:private",
            "geoip:cn"
          ]
        },
        {
          "type": "field",
          "outboundTag": "main",
          "port": "0-65535"
        }
      ]
    }
}
EOF
fi

if [ -f $V2RAY_GUI_CONFIG ];then
cat >$V2RAY_GUI_CONFIG <<EOF
{
  "appStatus": {
    "proxyState": true,
    "proxyMode": 2,
    "selectedServerIndex": 0,
    "selectedCusConfig": "",
    "selectedRoutingSet": 0,
    "useMultipleServer": false,
    "useCusProfile": false
  },
  "selectedPacFileName": "pac.js",
  "logLevel": "error",
  "localPort": 1080,
  "httpPort": 12333,
  "udpSupport": true,
  "shareOverLan": true,
  "dnsString": "8.8.8.8",
  "enableRestore": false,
  "profiles": [
    {
      "sendThrough": "0.0.0.0",
      "mux": {
        "enabled": true,
        "concurrency": 8
      },
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$V2RAY_IP",
            "users": [
              {
                "id": "$V2RAY_UID",
                "alterId": $V2RAY_ALERTID,
                "security": "$V2RAY_METHOD",
                "level": $V2RAY_LEVEL
              }
            ],
            "port": $V2RAY_PORT
          }
        ]
      },
      "tag": "do",
      "streamSettings": {
        "wsSettings": {
          "path": "/www",
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
          "serverName": "$V2RAY_IP",
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
    }
  ],
  "subscriptions": [],
  "routingRuleSets": [
    {
      "name": "全部使用主服务器",
      "domainStrategy": "AsIs",
      "rules": [
        {
          "type": "field",
          "port": "0-65535",
          "outboundTag": "main"
        }
      ]
    },
    {
      "name": "全部直连",
      "domainStrategy": "AsIs",
      "rules": [
        {
          "type": "field",
          "port": "0-65535",
          "outboundTag": "direct"
        }
      ]
    },
    {
      "name": "绕过本地和CN地址",
      "domainStrategy": "IPIfNonMatch",
      "rules": [
        {
          "type": "field",
          "outboundTag": "direct",
          "domain": [
            "localhost",
            "geosite:cn"
          ]
        },
        {
          "type": "field",
          "outboundTag": "direct",
          "ip": [
            "geoip:private",
            "geoip:cn"
          ]
        },
        {
          "type": "field",
          "outboundTag": "main",
          "port": "0-65535"
        }
      ]
    }
  ]
}
EOF
fi
