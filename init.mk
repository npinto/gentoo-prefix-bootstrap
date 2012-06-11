ifndef INIT_MK
INIT_MK=init.mk

include helpers.mk

EPREFIX?=${HOME}/gentoo

unexport LDFLAGS
unexport CPPFLAGS
unexport CHOST
unexport CC
unexport CXX
unexport HOSTCC
unexport CFLAGS
unexport CPLUS_INCLUDE_PATH
unexport LIBRARY_PATH
unexport INCLUDE_PATH
#unexport LD_LIBRARY_PATH
unexport CPATH
unexport C_INCLUDE_PATH
unexport DYLD_LIBRARY_PATH
unexport PYTHONPATH

N_PROCESSORS:=$(shell grep '^processor' /proc/cpuinfo | wc -l)
#MAKEOPTS:=-j$(shell echo ${N_PROCESSORS}+1 | bc) -l${N_PROCESSORS}
MAKEOPTS:=-j${N_PROCESSORS}

PATH:=${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX}/tmp/usr/bin:${EPREFIX}/tmp/bin:${EPREFIX}/usr/portage/scripts:${PATH}
#CHOST:="x86_64-pc-linux-gnu"

REAL_HOME:=$(shell readlink -f ~/)
ifeq (${HOME}, ${REAL_HOME})
  EMERGE:=emerge --quiet
else
  EMERGE:="cd ${REAL_HOME} && emerge --quiet"
endif

PIP:=pip
EIXSYNC:=eix-sync -q


endif
