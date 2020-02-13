#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    update_ssr.sh
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

source /usr/local/bin/alias/ssr.alias
cat >$SSR_CONFIG <<EOF
{
    "server": "$SSR_IP",
    "server_port": $SSR_PORT,
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "password": "$SSR_PASSWD",
    "method": "$SSR_METHOD",
    "protocol": "$SSR_PROTO",
    "protocol_param": "$SSR_PROTO_PARAM",
    "obfs": "$SSR_OBFS",
    "obfs_param": "$SSR_OBFS_PARAM",
    "speed_limit_per_con": 0,
    "speed_limit_per_user": 0,

    "additional_ports" : {},
    "additional_ports_only" : false,
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 1,
    "redirect": "",
    "fast_open": false
}
EOF

cat >$SSR_GUI_CONFIG <<EOF
{
	"configs" : [
		{
			"remarks" : "",
			"server" : "$SSR_IP",
			"server_port" : $SSR_PORT,
			"server_udp_port" : 0,
			"password" : "$SSR_PASSWD",
			"method" : "$SSR_METHOD",
			"protocol" : "$SSR_PROTO",
			"protocolparam" : "$SSR_PROTO_PARAM",
			"obfs" : "$SSR_OBFS",
			"obfsparam" : "$SSR_OBFS_PARAM",
			"remarks_base64" : "",
			"group" : "do",
			"enable" : true,
			"udp_over_tcp" : false
		}
	],
	"index" : 0,
	"random" : false,
	"sysProxyMode" : 1,
	"shareOverLan" : false,
	"localPort" : 1080,
	"dnsServer" : "",
	"reconnectTimes" : 2,
	"randomAlgorithm" : 3,
	"randomInGroup" : false,
	"TTL" : 0,
	"connectTimeout" : 5,
	"proxyRuleMode" : 2,
	"proxyEnable" : false,
	"pacDirectGoProxy" : false,
	"proxyType" : 0,
	"proxyHost" : "",
	"proxyPort" : 0,
	"proxyAuthUser" : "",
	"proxyAuthPass" : "",
	"proxyUserAgent" : "",
	"authUser" : "",
	"authPass" : "",
	"autoBan" : false,
	"sameHostForSameTarget" : false,
	"keepVisitTime" : 180,
	"isHideTips" : false,
	"nodeFeedAutoUpdate" : true,
	"serverSubscribes" : [

	],
	"token" : {

	},
	"portMap" : {

	}
}
EOF
