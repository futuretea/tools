#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    dell_t620_fan_speed_controler.sh host username password
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
    exit 1
fi

ipmi_host=$1
ipmi_user=$2
ipmi_passwd=$3

snmp_host=$1
snmp_ver="2c"
snmp_com="public"

# 三个温度值将转速划分区间,请结合自己的风扇和负载情况进行调整
temp_threshold="40,50,55,60,65"
fan_speed="10,15,20,30,40,50"

# 日志文件路径
log_dir="${HOME}/.cache"
log_path="${log_dir}/t620_ipmi_fan_speed_controller.log"
mkdir -p "${log_dir}"

# 检查是否已安装bc,snmpwalk,ipmitool
# sudo apt install snmp ipmitool snmp-mibs-downloader
# sudo download-mibs
for i in bc snmpwalk ipmitool; do
    if ! which "$i" >/dev/null; then
        echo "You need to install $i."
        exit 2  
    fi
done

# 获取当前的CPU温度
get_cpu1_temp=$(snmpwalk -v $snmp_ver -c $snmp_com "${snmp_host}" \
SNMPv2-SMI::enterprises.674.10892.5.4.700.20.1.6.1.2 | cut -d " " -f 4)
echo "cpu1 temp: ${get_cpu1_temp}"

get_cpu2_temp=$(snmpwalk -v $snmp_ver -c $snmp_com "${snmp_host}" \
SNMPv2-SMI::enterprises.674.10892.5.4.700.20.1.6.1.3 | cut -d " " -f 4)
echo "cpu2 temp: ${get_cpu2_temp}"

# 获取当前进气温度，用于写入日志
inlet_temp=$(snmpwalk -v $snmp_ver -c $snmp_com "${snmp_host}" \
SNMPv2-SMI::enterprises.674.10892.5.4.700.20.1.6.1.1 | cut -d " " -f 4)
echo "inlet temp: ${inlet_temp}"

# 计算CPU温度均值
calc_avg_temp=$(echo "($get_cpu1_temp + $get_cpu2_temp)/20" | bc)
echo "avg temp: ${calc_avg_temp}"

# 确定温度区间
if [ "$(echo "$calc_avg_temp > $(echo $temp_threshold | cut -d ',' -f 3)" | bc)" -eq 1 ]; then
  speed_range=4
elif [ "$(echo "$calc_avg_temp > $(echo $temp_threshold | cut -d ',' -f 2)" | bc)" -eq 1 ]; then
  speed_range=3
elif [ "$(echo "$calc_avg_temp > $(echo $temp_threshold | cut -d ',' -f 1)" | bc)" -eq 1 ]; then
  speed_range=2
else
  speed_range=1
fi
echo "speed_range: ${speed_range}"

speed_hex="0x"$(echo "obase=16; $(echo $fan_speed | cut -d ',' -f $speed_range)" | bc)
echo "speed: $(printf %d "${speed_hex}")"

inlet_temp=$((inlet_temp / 10))
fan_speed=$(echo $fan_speed | cut -d ',' -f $speed_range)%

# 判断日志文件是否存在
if [ -f $log_path ]; then
  # 获取最后一条日志中的转速区间值
  fan_speed_now=$(tail -n 1 "$log_path" | cut -d '=' -f 4 | cut -d ' ' -f 1)

  # 若目标区间值大于最后一条日志中的区间值，则立即上调转速，然后写入日志并退出程序
  if [ "$speed_range" -gt "$fan_speed_now" ]; then
    ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x02 0xff "$speed_hex"
    echo "$(date '+%Y-%m-%d %H:%M:%S') cpu_temp=$calc_avg_temp inlet_temp=$inlet_temp \
fan_speed_range=$speed_range fan_speed=$fan_speed msg=\"Cooling fan increases speed\"" >> "${log_path}"
    exit 0
  elif [ "$speed_range" -eq "$fan_speed_now" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') cpu_temp=$calc_avg_temp inlet_temp=$inlet_temp \
fan_speed_range=$fan_speed_now fan_speed=$fan_speed msg=\"Cooling fan maintains speed\"" >> "${log_path}"
    exit 0
  else
    # 获取最后10条日志中的CPU温度值并计算均值
    last_few_min_cpu_temp_avg=""
    for i in $(tail -n 10 "${log_path}");
    do
      i_tmp=$(echo "$i" | sed -e 's/^cpu_temp=\(.*\)/\1/g;t;d')
      if [ "$i_tmp" ]; then
        if [ "$last_few_min_cpu_temp_avg" ]; then
          last_few_min_cpu_temp_avg=$(echo "($last_few_min_cpu_temp_avg + $i_tmp)/2" | bc)
        else
          last_few_min_cpu_temp_avg=$i_tmp
        fi
      fi
    done
  fi
else
  # 若日志文件不存在，则立即调整转速并写入日志
  ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x02 0xff "$speed_hex"
  echo "$(date '+%Y-%m-%d %H:%M:%S') cpu_temp=$calc_avg_temp inlet_temp=$inlet_temp \
fan_speed_range=$speed_range fan_speed=$fan_speed msg=\"The log file does not exist, adjust the speed immediately\"" >> "${log_path}"
  exit 0
fi

# 若日志文件存在，但需要降低转速，则需要进行判断温度是否在合适的范围
# 当 “(最近10分钟的温度均值-最新CPU温度均值)/最新CPU温度均值” 大于0且小于0.03时，方可降低转速
#temp_calc=$(echo "scale=2; ($last_few_min_cpu_temp_avg - $calc_avg_temp)/$calc_avg_temp" | bc)
temp_calc=$((last_few_min_cpu_temp_avg - calc_avg_temp))

#if [ `echo "0 < $temp_calc" | bc` -eq 1 -a `echo "$temp_calc < 0.03" | bc` -eq 1 ]; then
if [ "$temp_calc" -le "-1" ]; then
  ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H "${ipmi_host}" -U "${ipmi_user}" -P "${ipmi_passwd}" raw 0x30 0x30 0x02 0xff "$speed_hex"
  echo "$(date '+%Y-%m-%d %H:%M:%S') cpu_temp=$calc_avg_temp inlet_temp=$inlet_temp \
fan_speed_range=$speed_range fan_speed=$fan_speed msg=\"Cooling fan reduces speed, $temp_calc\"" >> "${log_path}"
  exit 0
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') cpu_temp=$calc_avg_temp inlet_temp=$inlet_temp \
fan_speed_range=$fan_speed_now fan_speed=$fan_speed msg=\"Waiting for the temperature drop, $temp_calc\"" >> "${log_path}"
  exit 0
fi
