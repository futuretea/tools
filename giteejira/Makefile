all: config
.PHONY: install
config:
	cp var.src var
	vi var
install:
	mkdir -p ${HOME}/.config/giteejira
	cp alias ${HOME}/.config/giteejira/alias
	cp var ${HOME}/.config/giteejira/var
uninstall:
	rm -rf ${HOME}/.config/giteejira
clean:
	rm var
