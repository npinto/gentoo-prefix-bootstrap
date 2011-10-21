#!/bin/bash

# ============================================================================
# Bootstrap a Scientific Gentoo Prefix in $HOME/gentoo.
# ============================================================================
#
#
# Usage:
# ------
# To install everything:
# $ make
# (XXX: right now this just install the system)
#
# To just install the system:
# $ make install_gentoo_prefix
#
# To just install the system tools (eix, layman, etc.):
# $ make install_system_tools (TODO)
#
# To just install the scientfic/development environment
# (atlas, python, numpy, scipy, mongo, etc.):
# $ make install_scientific_environment (TODO)
#
#
# More information about Gentoo Prefix:
# -------------------------------------
#
# * http://www.gentoo.org/proj/en/gentoo-alt/prefix/
# * http://www.gentoo.org/proj/en/gentoo-alt/prefix/usecases.xml
# * http://www.gentoo.org/proj/en/gentoo-alt/prefix/bootstrap-solaris.xml
# ============================================================================

N_PROCESSORS:=$(shell cat /proc/cpuinfo  | grep processor | wc -l)
MAKEOPTS:=-j$(shell echo ${N_PROCESSORS}+1 | bc)

EPREFIX:=${HOME}/gentoo
PATH:=${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX}/tmp/usr/bin:${EPREFIX}/tmp/bin:${PATH}

# ----------------------------------------------------------------------------
default: install_gentoo_prefix


# ============================================================================
# == install_gentoo_prefix
# ============================================================================

install_gentoo_prefix: stage0 stage1 stage2 stage3 stage4

# ----------------------------------------------------------------------------
# -- STAGE 0
# ----------------------------------------------------------------------------
stage0: bootstrap-prefix-patched.sh

bootstrap-prefix-patched.sh:
	# Grab latest bootstrap-prefix-patched.sh
	wget -O bootstrap-prefix.sh http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt

	# Patch to disable python crypt and nis modules
	# For more info:
	# * https://bugs.gentoo.org/show_bug.cgi?id=381163
	# * http://archives.gentoo.org/gentoo-alt/msg_a1856438065eec550b5bf410488db9bb.xml
	wget https://raw.github.com/gist/1294750/d96a4b0f2be742dcca3adcb220a603b2260c4cc9/bootstrap-prefix-python-disable-crypt-nis.patch
	patch -p0 < bootstrap-prefix-python-disable-crypt-nis.patch
	mv -vf bootstrap-prefix.sh bootstrap-prefix-patched.sh
	chmod 755 bootstrap-prefix-patched.sh

# ----------------------------------------------------------------------------
# -- STAGE 1
# ----------------------------------------------------------------------------
stage1: bootstrap-prefix-patched.sh
	./bootstrap-prefix-patched.sh ${EPREFIX} tree
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp make
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp wget
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp sed
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp coreutils6
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp findutils5
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp tar15
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp patch
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp grep
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp gawk
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp bash
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp zlib
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp python
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp bison
	./bootstrap-prefix-patched.sh ${EPREFIX} portage
	touch $@.done

# ----------------------------------------------------------------------------
# -- STAGE 2
# ----------------------------------------------------------------------------
stage2: stage1.done stage2-up-to-bison.done stage2-binutils.done stage2-gcc.done stage2-up-to-pax-utils.done stage2-portage.done
	touch $@.done

stage2-up-to-bison: stage1.done
	emerge --oneshot sed
	emerge --oneshot --nodeps bash
	emerge --oneshot --nodeps xz-utils
	emerge --oneshot wget
	emerge --oneshot --nodeps baselayout-prefix
	emerge --oneshot --nodeps m4
	emerge --oneshot --nodeps flex
	emerge --oneshot --nodeps bison
	touch $@.done

stage2-binutils: stage2-up-to-bison.done
	emerge --oneshot --nodeps binutils-config
	# XXX: MAKEOPTS in env/... ?
	#MAKEOPTS=-j1 emerge --oneshot --nodeps binutils
	#MAKEOPTS=-j1 emerge --oneshot --nodeps "~binutils-2.20.1-r1"
	# work around binutils:
	ebuild --skip-manifest ${EPREFIX}/usr/portage/sys-devel/binutils/binutils-2.20.1-r1.ebuild clean merge
	touch $@.done

stage2-gcc: stage2-binutils.done
	emerge --oneshot --nodeps gcc-config
	emerge --oneshot --nodeps "=gcc-4.2*"
	touch $@.done

#stage2-gcc-workarounds: stage2-binutils.done
	## errno.h missing
	#emerge --oneshot linux-headers
	# XXX: to test 'tar' (FIX dicarlo2 problem on tar overflow?)
	#emerge --oneshot tar
	## lib{c,m}.so missing
	#ln -sf $(ldd /usr/bin/awk | grep libc.so | awk '{print $3}') ${EPREFIX}/usr/lib/libc.so
	#ln -sf $(ldd /usr/bin/awk | grep libm.so | awk '{print $3}') ${EPREFIX}/usr/lib/libm.so
	#touch $@.done

#stage2-up-to-pax-utils: stage2-gcc-workarounds.done stage2-gcc.done
stage2-up-to-pax-utils: stage2-gcc.done
	emerge --oneshot coreutils
	emerge --oneshot findutils
	emerge --oneshot tar
	emerge --oneshot grep
	emerge --oneshot patch
	emerge --oneshot gawk
	emerge --oneshot make
	emerge --oneshot --nodeps file
	emerge --oneshot --nodeps eselect
	emerge --oneshot pax-utils
	touch $@.done

stage2-portage-workarounds: stage2-up-to-pax-utils.done
	# python workaround
	mkdir -p ${EPREFIX}/etc/portage/env/dev-lang/
	echo "export LDFLAGS='-L/usr/lib64'" >> ${EPREFIX}/etc/portage/env/dev-lang/python
	# libxml2 workaround
	mkdir -p ${EPREFIX}/etc/portage/env/dev-libs
	#echo "export LDFLAGS=-l:$$(ls ${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-libs/libxml2
	echo "export LDFLAGS=-l:\$$(ls ${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-libs/libxml2
	touch $@.done

stage2-portage: stage2-up-to-pax-utils.done stage2-portage-workarounds.done
	# Update portage
	env FEATURES="-collision-protect" emerge --oneshot portage
	mkdir -p ${EPREFIX}/etc/portage/package.{keywords,use}
	# Clean up tmp dir
	rm -Rf ${EPREFIX}/tmp/*
	# Synchronize repo
	emerge --sync
	touch $@.done

# ----------------------------------------------------------------------------
# -- STAGE 3
# ----------------------------------------------------------------------------
stage3: stage2.done stage3-workarounds.done
	# Update system
	emerge -u system
	touch $@.done

stage3-workarounds: stage2.done
	# git workaround
	USE="-git" emerge --oneshot --nodeps gettext
	emerge --oneshot git
	# gcc workaround
	echo 'sys-devel/gcc vanilla' >> ${EPREFIX}/etc/portage/package.use/gcc
	emerge -u gcc
	#gcc-config 2
	#source ${EPREFIX}/etc/profile
	# XXX: remove old one?
	# XXX: MAKEOPTS in env
	# groff workaround
	mkdir -p ${EPREFIX}/etc/portage/env/sys-apps
	echo "export MAKEOPTS=-j1" >> ${EPREFIX}/etc/portage/env/sys-apps/groff
	#MAKEOPTS=-j1 emerge -u groff
	touch $@.done

# ----------------------------------------------------------------------------
# -- STAGE 4
# ----------------------------------------------------------------------------
stage4: stage3.done stage4-config.done stage4-workarounds.done
	# -- recompile entire system
	emerge -vej system world
	touch $@.done

stage4-config: stage3.done make.conf
	# -- Update make.conf
	cp -vf make.conf ${EPREFIX}/etc/
	echo "MAKEOPTS=${MAKEOPTS}" >> ${EPREFIX}/etc/make.conf
	# -- python USE
	echo 'dev-lang/python sqlite wide-unicode berkdb' >> ${EPREFIX}/etc/portage/package.use/python
	touch $@.done

stage4-workarounds: stage3.done stage4-config.done
	# -- gcc workaround
	#USE=-fortran emerge -uDN gcc
	USE=-fortran emerge --nodeps gcc
	#gcc-config 2
	#source ${EPREFIX}/etc/profile
	# -- mpc workaround
	mkdir -p ${EPREFIX}/etc/portage/env/dev-libs
	echo "export LDFLAGS=-L${EPREFIX}/usr/lib" >> ${EPREFIX}/etc/portage/env/dev-libs/mpc
	#emerge mpc
	# -- openssh workaround
	mkdir -p ${EPREFIX}/etc/portage/env/net-misc
	echo "export LDFLAGS=\"-l:${EPREFIX}/usr/lib/libssl.so -l:${EPREFIX}/usr/lib/libcrypto.so\"" >> ${EPREFIX}/etc/portage/env/net-misc/openssh
	emerge openssh
	touch $@.done

# ============================================================================
# -- Helpers
# ============================================================================
clean:
	rm -rf ${EPREFIX}
	rm -f bootstrap-prefix-patched.sh
	rm -f bootstrap-prefix-*.patch
	rm -f *.done

backup: ${EPREFIX}
	mv -vf ${EPREFIX} ${EPREFIX}-backup-$(date +"%Y-%m-%d_%Hh%Mm%Ss")
