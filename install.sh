#!/bin/zsh

sudo chsh mate -s /bin/zsh
sudo ./shell/load.sh .
sudo ./alias/src.sh .
./zsh/install_zsh_plugin.sh
cp zsh/.zshrc ~
cp zsh/starship.toml ~/.config/

