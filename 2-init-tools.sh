#!/bin/bash

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# install asdf
if [[ ! -d ~/.asdf ]];then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
fi

# install starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
