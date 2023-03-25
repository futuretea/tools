#!/bin/bash

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# install asdf
if [[ ! -d ~/.asdf ]];then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
fi

# install asdf plugin
asdf plugin add kubectx
asdf plugin add kubecm
asdf plugin add kubectl
asdf plugin add terraform
asdf plugin add kubetail https://github.com/janpieper/asdf-kubetail.git
asdf plugin add helm https://github.com/Antiarchitect/asdf-helm.git
asdf plugin add k9s https://github.com/looztra/asdf-k9s
asdf plugin add autok3s https://github.com/futuretea/asdf-autok3s.git
asdf plugin add kube-explorer https://github.com/futuretea/asdf-kube-explorer.git
asdf plugin add golangci-lint https://github.com/hypnoglow/asdf-golangci-lint.git
asdf plugin add gossh https://github.com/futuretea/asdf-gossh.git

# install kubectl
asdf install kubectl latest
asdf global kubectl latest

# install starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
