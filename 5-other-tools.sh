#!/bin/bash

# install dev tools
sudo apt install silversearcher-ag fd-find unzip tree python3-pip ansible neovim tmux socat mtr net-tools httpie jq -y
if [[ ! -L /usr/local/bin/fd ]];then
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
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

go install github.com/rs/curlie@latest
go install golang.org/x/tools/cmd/goimports@latest

pip install nginxfmt
