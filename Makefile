# --------------------------------------------------------------------------------
# Define customizable variables:
# --------------------------------------------------------------------------------
sdk_git_repo = git clone --recursive https://github.com/pfalcon/esp-open-sdk
sdk_subdir = esp-open-sdk

# --------------------------------------------------------------------------------
# Define utility variables and functions:
# --------------------------------------------------------------------------------
# Currently only Debian-based Linux is supported:
define mandate_platforms
	@if [ -z "$$(grep 'Ubuntu\|Debian' /etc/lsb-release)" ]; then \
		echo "ERROR: Platform not supported"; \
	fi
endef

define install_linux_package
	@$(mandate_platforms)
	@if [ ! -f $(2) ]; then \
		echo ; \
		echo Note: Installing $(1) which provides $(2); \
		echo ; \
		sudo apt-get -y install $(1); \
		if [ ! -f $(2) ]; then \
			echo ; \
			echo ERROR: Installing $(1) did not provide $(2) as expected; \
			echo ; \
			exit 1; \
		fi; \
	fi
endef

# --------------------------------------------------------------------------------
# Define rules:
# --------------------------------------------------------------------------------
.PHONY: all
all: build

# Reference the build instructions at http://www.esp8266.com/wiki/doku.php?id=toolchain

.PHONY: build
build: build-sdk
	echo "TODO build the local firmware in this directory from this rule"

.PHONY: load
load: build
	echo DISABLED make -C $(sdk_subdir) todo add something here for the python loader

.PHONY: clean
clean:
	make -C $(sdk_subdir) clean
	cd $(sdk_subdir); git pull
	cd $(sdk_subdir); git submodule sync
	cd $(sdk_subdir); git submodule update --init

# Just build the STANDALONE mode:
.PHONY: build-sdk
build-sdk: $(sdk_subdir)/xtensa-lx106-elf/.done

$(sdk_subdir)/xtensa-lx106-elf/.done : apply-patches
	cd $(sdk_subdir); make
	@touch $@

.PHONY: apply-patches
apply-patches : download-sdk
	@echo 'Hack around bug: Ensure that $$(TOOLCHAIN)/bin exists before esptool rule copies things into it:'
	mkdir -p $(sdk_subdir)/xtensa-lx106-elf/bin

.PHONY: download-sdk
download-sdk: install-packages
	@$(mandate_platforms)
	@if [ ! -d ./$(sdk_subdir) ]; then \
		echo ; \
		echo Note: Downloading sdk from $(sdk_git_repo) ...; \
		echo ; \
		git clone --recursive $(sdk_git_repo); \
		if [ ! -d ./$(sdk_subdir) ]; then \
			echo ; \
			echo ERROR: Installing $(sdk_git_repo) did not provide ./$(sdk_subdir) as expected; \
			echo ; \
			exit 1; \
		fi; \
	else \
		echo ; \
		echo Note: Updating sdk from $(sdk_git_repo) ...; \
		echo ; \
		(cd $(sdk_subdir); git pull); \
	fi

.PHONY: install-packages
install-packages: 
	$(call install_linux_package,make,/usr/bin/make)
	$(call install_linux_package,unrar,/usr/bin/unrar)
	$(call install_linux_package,autoconf,/usr/bin/autoconf)
	$(call install_linux_package,automake,/usr/bin/automake)
	$(call install_linux_package,libtool,/usr/bin/libtoolize)
	$(call install_linux_package,gcc,/usr/bin/gcc)
	$(call install_linux_package,g++,/usr/bin/g++)
	$(call install_linux_package,gperf,/usr/bin/gperf)
	$(call install_linux_package,flex,/usr/bin/flex)
	$(call install_linux_package,bison,/usr/bin/bison)
	$(call install_linux_package,texinfo,/usr/bin/texi2pdf)
	$(call install_linux_package,gawk,/usr/bin/gawk)
	$(call install_linux_package,ncurses-dev,/usr/bin/ncurses5-config)
	$(call install_linux_package,libexpat-dev,/usr/include/expat.h)
	$(call install_linux_package,python,/usr/bin/python)
	$(call install_linux_package,python-serial,/usr/bin/miniterm.py)
	$(call install_linux_package,sed,/bin/sed)
	$(call install_linux_package,git,/usr/bin/git)
	$(call install_linux_package,unzip,/usr/bin/unzip)
	$(call install_linux_package,bash,/bin/bash)
	$(call install_linux_package,libtool-bin,/usr/bin/libtool)
	$(call install_linux_package,help2man,/usr/bin/help2man)
