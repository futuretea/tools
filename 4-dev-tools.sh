#!/bin/bash

# install dev tools
sudo apt install silversearcher-ag fd-find unzip tree python3-pip ansible neovim tmux socat mtr net-tools httpie jq -y
if [[ ! -L /usr/local/bin/fd ]];then
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
fi
