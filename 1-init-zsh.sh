#!/bin/bash

# install zsh (multi-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS (Homebrew)
  brew install zsh
elif [[ -f /etc/debian_version ]]; then
  # Debian/Ubuntu
  sudo apt-get update
  sudo apt-get install -y zsh
elif [[ -f /etc/redhat-release ]]; then
  # RHEL/CentOS/Fedora
  sudo yum install -y zsh || sudo dnf install -y zsh
else
  echo "Please install zsh manually for your platform."
fi

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
