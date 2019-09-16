#!/bin/bash
set -e

useage(){
    echo "useage:"
    echo "  vminit NAME BOX NUM MEM CPU IPBASE [DISKS...]"
}

if [ $# -lt 6 ];then
    useage
    exit
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
cat >"${NAME}"/Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :
EOF

cat >>"${NAME}"/Vagrantfile <<EOF
Vagrant.configure("2") do |config|
  (1..${NUM}).each do |i|
    config.vm.define "node#{i}" do |node|
      node.ssh.username = 'root'
      node.ssh.password = 'vagrant'
      # node.ssh.insert_key = false
      node.vm.box = '${BOX}'
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.network :private_network, :ip => "${IPBASE}.#{100+i}"
      node.vm.provider :libvirt do |domain|
        domain.driver = 'kvm'
        domain.memory = ${MEM}
        domain.cpus = ${CPU}
        domain.nested = true
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

cat >>"${NAME}"/provision.sh <<EOFF
#!/bin/bash
sed -ri 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cat >>/etc/ssh/sshd_config <<EOF
PermitRootLogin yes
UseDNS no
systemctl restart sshd
EOF
EOFF
