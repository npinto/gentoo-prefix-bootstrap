include helpers.mk

EPREFIX?=${HOME}/gentoo

N_PROCESSORS:=$(shell grep '^processor' /proc/cpuinfo | wc -l)
MAKEOPTS:=-j$(shell echo ${N_PROCESSORS}+1 | bc) -l${N_PROCESSORS}

PATH:=${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX}/tmp/usr/bin:${EPREFIX}/tmp/bin:${PATH}


