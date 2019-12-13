#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    vminit BOX NAME START END MEM CPU IPBASE [DISKS...]
    eg:
      vminit centos-7-1905.1-libvirt demohost 192.168.50 10 19 2 2048 20G 10G
EOF
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 7 ];then
    useage
    exit 1
fi

BOX=$1
NAME=$2
IPBASE=$3
START=$4
END=$5
CPU=$6
MEM=$7
shift 7
DISKS=$@

mkdir -p "${NAME}"
cd "${NAME}"

net_exists=0
for net in $(virsh net-list --all --name | xargs -r ); do
  if [[ x"$NAME" == x"$net" ]];then
    net_exists=1
  fi
done

ip2mac(){
  local MAC=$1
  local IP=$2
  for index in {1..4}; do
      ipi=$(echo "${IP}" | cut -d "." -f "${index}")
      maci=$(echo "obase=16;${ipi}" | bc)
      MAC="${MAC}"':'"${maci}"
  done
  echo "${MAC}"
}

if [[ $net_exists -eq 0 ]];then
cat >network.xml <<EOF
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

for ((i=2;i<=254;i++)); do
IP="${IPBASE}.$i"
MAC=$(ip2mac "50:50" "${IP}")
cat >>network.xml <<EOF
      <host mac="${MAC}" ip="${IP}"/>
EOF
done

cat >>network.xml <<EOF
    </dhcp>
  </ip>
</network>
EOF

virsh net-define --file ./network.xml
fi

cat >Vagrantfile <<EOF
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
  (${START}..${END}).each do |i|
    config.vm.define "$NAME#{i}" do |node|
      # node.ssh.username = 'root'
      # node.ssh.password = 'vagrant'
      node.ssh.insert_key = true
      node.vm.box = '${BOX}'
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.provider :libvirt do |domain|
        domain.driver = 'kvm'
        domain.memory = ${MEM}
        domain.cpus = ${CPU}
        domain.nested = true
        domain.management_network_name = "${NAME}"
        domain.management_network_address = "${IPBASE}.0/24"
        domain.management_network_mac = ip2mac("50:50","${IPBASE}.#{i}")
EOF

for DISK in ${DISKS};do
cat >>Vagrantfile <<EOF
        domain.storage :file, :size => '${DISK}', :bus => 'virtio'
EOF
done

cat >>Vagrantfile <<EOF
      end
      node.vm.provision :shell, :path => 'provision.sh'
    end
  end
end
EOF

cat >provision.sh <<EOFF
#!/bin/bash
sed -ri 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cat >>/etc/ssh/sshd_config <<EOF
PermitRootLogin yes
UseDNS no
systemctl restart sshd
EOF
EOFF

vagrant up
