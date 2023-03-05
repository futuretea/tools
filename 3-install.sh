#!/bin/bash

sudo ./shell/load.sh .
sudo ./alias/src.sh .
cp zsh/.zshrc ~
cp zsh/.bash_aliases ~
cp zsh/.tmux.conf ~
mkdir -p ~/.config
cp zsh/starship.toml ~/.config/
./zsh/install_zsh_plugin.sh
sudo ./shell/suu.sh $USER
