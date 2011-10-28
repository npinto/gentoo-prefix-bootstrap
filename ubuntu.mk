include Makefile

default: uninstall-force install/stage1 install/stage2-up-to-bison
    emerge --nodeps --oneshot binutils
    emerge --nodeps --oneshot gcc-config
    emerge --nodeps app-arch/tar
    LIBRARY_PATH=$(shell echo $(shell dirname $(shell echo $(shell find /usr/lib/ -name "libc.so" | tail -n1))))/../ INCLUDE_PATH=$(shell echo $(shell dirname $(shell echo $(shell find /usr/include/ -name 'errno.h' | grep -e '/asm/errno.h' | tail -n1))))/../ emerge --oneshot --nodeps "=gcc-4.2*"


