#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    vminit NAME BOX NUM MEM CPU IPBASE [DISKS...]
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 6 ];then
    useage
    exit 1
fi

NAME=$1
BOX=$2
NUM=$3
MEM=$4
CPU=$5
IPBASE=$6
shift 6
DISKS=$@

mkdir -p "${NAME}"

cat >"${NAME}"/network.xml <<EOF
<network ipv6="yes">
  <name>${NAME}</name>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535"/>
    </nat>
  </forward>
  <bridge name="${NAME}br" stp="on" delay="0"/>
  <ip address="${IPBASE}.1" netmask="255.255.255.0">
    <dhcp>
      <range start="${IPBASE}.2" end="${IPBASE}.254"/>
EOF

ip2mac(){
  local IP=$1
  local MAC='55:55'
  for index in {1..4}; do
      ipi=$(echo "${IP}" | cut -d "." -f "${index}")
      maci=$(echo "obase=16;${ipi}" | bc)
      MAC="${MAC}"':'"${maci}"
  done
  echo "${MAC}"
}

for ((i=1;i<=$NUM;i++)); do
IP="${IPBASE}.$((100+$i))"
MAC=$(ip2mac "${IP}")
cat >>"${NAME}"/network.xml <<EOF
      <host mac="${MAC}" ip="${IP}"/>
EOF
done

cat >>"${NAME}"/network.xml <<EOF
    </dhcp>
  </ip>
</network>
EOF

cat >"${NAME}"/Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

def ip2mac(prefix, str_ip)
	@mac=prefix
	str_ip.split('.').each do |k|
		k="%02x" % k
		@mac=@mac+":"+k.to_s
	end
	return @mac
end

Vagrant.configure("2") do |config|
  (1..${NUM}).each do |i|
    config.vm.define "$NAME#{i}" do |node|
      node.ssh.username = 'root'
      node.ssh.password = 'vagrant'
      node.ssh.insert_key = false
      node.vm.box = '${BOX}'
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.provider :libvirt do |domain|
        domain.driver = 'kvm'
        domain.memory = ${MEM}
        domain.cpus = ${CPU}
        domain.nested = true
        domain.management_network_name = "${NAME}"
        domain.management_network_address = "${IPBASE}.0/24"
        domain.management_network_mac = ip2mac("55:55","${IPBASE}.#{100+i}")
EOF

for DISK in ${DISKS};do
cat >>"${NAME}"/Vagrantfile <<EOF
        domain.storage :file, :size => '${DISK}', :bus => 'virtio'
EOF
done

cat >>"${NAME}"/Vagrantfile <<EOF
      end
      node.vm.provision :shell, :path => 'provision.sh'
    end
  end
end
EOF

cat >"${NAME}"/provision.sh <<EOFF
#!/bin/bash
sed -ri 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cat >>/etc/ssh/sshd_config <<EOF
PermitRootLogin yes
UseDNS no
systemctl restart sshd
EOF
EOFF
