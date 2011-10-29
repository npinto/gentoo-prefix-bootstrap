
default: install/stage1 install/stage2-up-to-bison gcc-ubuntu install/stage2-portage  install/stage3 install/stage4

include init.mk
include system.mk


gcc-ubuntu:
	emerge --nodeps --oneshot binutils
	emerge --nodeps --oneshot gcc-config
	emerge --nodeps app-arch/tar
	LIBRARY_PATH=$(shell echo $(shell dirname $(shell echo $(shell find /usr/lib/ -name "libc.so" | tail -n1)))) INCLUDE_PATH=$(shell echo $(shell dirname $(shell echo $(shell find /usr/include/ -name 'errno.h' | grep -e '/asm/errno.h' | tail -n1))))/../ emerge --oneshot --nodeps "=gcc-4.2*"
	touch install/stage2-binutils
	touch install/stage2-gcc
	touch $@

