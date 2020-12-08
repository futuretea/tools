all:
	#sudo chsh mate -s /bin/zsh
	sudo ./shell/load.sh .
	sudo ./alias/src.sh .
	cp zsh/.zshrc ~
	cp zsh/.bash_aliases ~
	cp zsh/.tmux.conf ~
	mkdir -p ~/.config
	cp zsh/starship.toml ~/.config/
	./zsh/install_zsh_plugin.sh

