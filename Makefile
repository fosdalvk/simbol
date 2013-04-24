export MAKEFLAGS := --no-print-directory

ifeq (${PROFILE},)
$(error PROFILE is not set)
endif

reinstall: uninstall install

install: extern
	@mkdir -p $(HOME)/.site $(HOME)/bin
	@
	@rm -f $(HOME)/.site/lib
	ln -sf $(PWD)/lib $(HOME)/.site/lib
	@rm -f $(HOME)/.site/etc
	ln -sf $(PWD)/etc $(HOME)/.site/etc
	@rm -f $(HOME)/.site/libexec
	ln -sf $(PWD)/libexec $(HOME)/.site/libexec
	@
	ln -sf $(PWD)/share $(HOME)/.site/share
	@
	ln -sf $(PWD)/bin/site $(HOME)/bin/site
	@echo "Install complete."

extern:
	@make -C $@
	@
	@mkdir -p $(HOME)/.site/extern
	@ln -sf $(PWD)/extern/shflags $(HOME)/.site/extern/shflags
	@ln -sf $(PWD)/extern/shunit2 $(HOME)/.site/extern/shunit2

uninstall:
	rm -rf $(HOME)/.site
	rm -rf $(HOME)/bin/site
	@make -C extern clean
	@echo "Uninstall complete."

.PHONY: install reinstall uninstall extern