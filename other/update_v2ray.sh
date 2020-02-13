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
cat >$V2RAY_CONFIG <<EOF
{
  "log": {
    // "access": "/path/to/access/log/file",
    // "error": "/path/to/error/log/file",
    "loglevel": "warning"
  },
  "inbounds": [
	  {
		"port": 1080,
		"listen": "127.0.0.1",
		"tag": "socks-inbound",
		"protocol": "socks",
		"settings": {
			"auth": "noauth",
			"udp": false,
			"ip": "127.0.0.1"
		},
		"sniffing": {
			"enabled": false,
			"destOverride": ["http", "tls"]
		}
  	},
	{
		"port": 12333,
		"listen": "127.0.0.1",
		"protocol": "http",
		"settings": {
			"auth": "noauth",
			"udp": true,
			"ip": "127.0.0.1"
		}
	}
  ],
  "outbounds": [
	{
		"protocol": "vmess",
		"settings": {
			"vnext": [
				{
					"address": "$V2RAY_IP",
					"port": $V2RAY_PORT,
					"users": [
						{
							"id": "$V2RAY_UID",
							"alterId": $V2RAY_ALERTID,
							"security": "$V2RAY_METHOD"
						}
					]
				}
			]
		},
		"mux": {
            "enabled": true
        }
  },{
    "protocol": "freedom",
    "settings": {},
    "tag": "direct"
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],

  //"transport": {},

  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules":[
      {
        // Blocks access to private IPs. Remove this if you want to access your router.
        "type": "field",
        "ip": [
			"geoip:private"
		],
        "outboundTag": "blocked"
      },
      {
        // Blocks major ads.
        "type": "field",
        "domain": [
			"geosite:category-ads"
		],
        "outboundTag": "blocked"
      }
    ]
  },

  // Dns settings for domain resolution.
  "dns": {
    "hosts": {
      "domain:github.io": "pages.github.com",
      "domain:wikipedia.org": "www.wikimedia.org",
      "domain:shadowsocks.org": "electronicsrealm.com"
    },
    "servers": [
      "1.1.1.1",
      {
        "address": "114.114.114.114",
        "port": 53,
        "domains": [
          "geosite:cn"
        ]
      },
      "8.8.8.8",
      "localhost"
    ]
  },

  // Policy controls some internal behavior of how V2Ray handles connections.
  // It may be on connection level by user levels in 'levels', or global settings in 'system.'
  "policy": {
    // Connection policys by user levels
    "levels": {
      "0": {
        "uplinkOnly": 0,
        "downlinkOnly": 0
      }
    },
    "system": {
      "statsInboundUplink": false,
      "statsInboundDownlink": false
    }
  },

  // Stats enables internal stats counter.
  // This setting can be used together with Policy and Api.
  //"stats":{},

  // Api enables gRPC APIs for external programs to communicate with V2Ray instance.
  //"api": {
    //"tag": "api",
    //"services": [
    //  "HandlerService",
    //  "LoggerService",
    //  "StatsService"
    //]
  //},

  "other": {}
}
EOF

cat >$V2RAY_GUI_CONFIG <<EOF
{
  "appStatus": {
    "proxyState": true,
    "proxyMode": 2,
    "selectedServerIndex": 0,
    "selectedCusConfig": "",
    "selectedRoutingSet": 2,
    "useMultipleServer": false,
    "useCusProfile": false
  },
  "selectedPacFileName": "pac.js",
  "logLevel": "debug",
  "localPort": 1080,
  "httpPort": 8001,
  "udpSupport": false,
  "shareOverLan": true,
  "dnsString": "8.8.8.8",
  "enableRestore": false,
  "profiles": [
    {
      "sendThrough": "0.0.0.0",
      "mux": {
        "enabled": false,
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
          "serverName": "server.cc",
          "allowInsecureCiphers": false
        },
        "httpSettings": {
          "path": ""
        },
        "kcpSettings": {
          "header": {
            "type": "none"
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
        "security": "none",
        "network": "tcp",
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
