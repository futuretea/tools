#!/bin/bash

# install base
sudo apt install make zsh

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# install starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
