#!/bin/bash -eux
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo 'options kvm_intel nested=1' > /etc/modprobe.d/kvm.conf
cat /sys/module/kvm_intel/parameters/nested
