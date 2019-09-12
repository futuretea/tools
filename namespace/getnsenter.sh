#!/bin/bash
set -e
proxychains wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.gz
tar -zxf util-linux-2.34.tar.gz
cd util-linux-2.34
./configure --without-ncurses
make nsenter
sudo cp nsenter /usr/local/bin
cd ..
rm -rf util-linux-2.34
