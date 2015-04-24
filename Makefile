.PHONY: default help install

PROG 		= nagios-api
DIR  		= /usr/local/bin/nagios-api
Q               = @
bold            = $(shell tput bold)
underline       = $(shell tput smul)
normal          = $(shell tput sgr0)
red             = $(shell tput setaf 1)
yellow          = $(shell tput setaf 3)

default: help

help:
	$(Q)echo "$(bold)$(PROG) install targets:$(normal)"
	$(Q)echo " $(red)install$(normal)                       - Install $(PROG)"
	$(Q)echo " $(red)uninstall$(normal)                     - Uninstalls $(PROG)"

install:
	mkdir -m 755 -p $(DIR)
	install -o root -g root -m 750 bottle.py $(DIR)/bottle.py
	install -o root -g root -m 750 nagios-api.py $(DIR)/nagios-api.py
	install -o root -g root -m 644 nagios-api.conf /etc/init/nagios-api.conf
	$(Q)echo " $(bold)--> Edit $(normal)$(underline)nagios-api.py$(normal) with your machine's IP on the last line"

uninstall:
	$(Q)echo " $(yellow)Uninstalling $(PROG)$(normal)"
	rm -rf $(DIR)
