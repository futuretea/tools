#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<"EOF"
USAGE:
    install_vagrant_libvirt.sh
EOF
}

exit_err() {
   echo >&2 $1
   exit 1
}

if [ $# -lt 0 ];then
    useage
    exit 1
fi

ln -s /usr/include/libxml2/libxml /usr/include/libxml
CONFIGURE_ARGS='with-ldflags=-L/opt/vagrant/embedded/lib with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' GEM_HOME=~/.vagrant.d/gems GEM_PATH=$GEM_HOME:/opt/vagrant/embedded/gems PATH=/opt/vagrant/embedded/bin:$PATH proxychains vagrant plugin install vagrant-libvirt
