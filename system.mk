ifndef SYSTEM_MK
SYSTEM_MK=system.mk

include init.mk

system: install/stage0 install/stage1 install/stage2 install/stage3 install/stage4

# ----------------------------------------------------------------------------
# -- STAGE 0
# ----------------------------------------------------------------------------
install/stage0: bootstrap-prefix-patched.sh
	mkdir -p install
	touch $@

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
# -- install/stage 1
# ----------------------------------------------------------------------------
install/stage1: bootstrap-prefix-patched.sh
	# XXX: do we need this ?: /bin/bash --norc --noprofile
	# export HOME
	# export EPREFIX
	# export PATH
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
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp zlib
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp python
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp m4
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp bison
	./bootstrap-prefix-patched.sh ${EPREFIX}/tmp bash
	# XXX: hash -r (for cmd line)
	./bootstrap-prefix-patched.sh ${EPREFIX} portage
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 2
# ----------------------------------------------------------------------------
install/stage2: install/stage1 install/stage2-up-to-bison \
	install/stage2-binutils install/stage2-gcc install/stage2-up-to-patch \
	install/stage2-gawk install/stage2-up-to-pax-utils install/stage2-portage
	touch $@

install/stage2-up-to-bison: install/stage1
	# export LDFLAGS="-L${EPREFIX}/usr/lib -R${EPREFIX}/usr/lib -L${EPREFIX}/lib -R${EPREFIX}/lib"
	# export CPPFLAGS="-I${EPREFIX}/usr/include"
	# hash -r
	# export USE="-berkdb -fortran -gdbm -nls -pcre -ssl -pam"
	${EMERGE} --oneshot sed
	${EMERGE} --oneshot --nodeps bash
	${EMERGE} --oneshot --nodeps xz-utils
	${EMERGE} --oneshot wget
	${EMERGE} --oneshot --nodeps baselayout-prefix
	${EMERGE} --oneshot --nodeps m4
	${EMERGE} --oneshot --nodeps flex
	${EMERGE} --oneshot --nodeps bison
	touch $@

install/stage2-binutils: install/stage2-up-to-bison
	${EMERGE} --oneshot --nodeps binutils-config
	# ${EMERGE} --oneshot --nodeps binutils
	#FEATURES=-strict ${EMERGE} --oneshot --nodeps "~binutils-2.20.1-r1"
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps binutils || MAKEOPTS=-j1 ebuild --skip-manifest ${EPREFIX}/usr/portage/sys-devel/binutils/binutils-2.20.1-r1.ebuild clean merge
	touch $@

install/stage2-gcc: install/stage2-binutils
	${EMERGE} --oneshot --nodeps gcc-config
	# errno.h missing
	#${EMERGE} --oneshot --nodeps linux-headers
	${EMERGE} --oneshot --nodeps "=gcc-4.2.4-r01.4"
	echo ">sys-devel/gcc-4.2.4-r01.4" > ${EPREFIX}/etc/portage/package.mask/gcc-4.2.4-r01.4+
	touch $@

install/stage2-up-to-patch: install/stage2-gcc
	# unset LDFLAGS CPPFLAGS CHOST CC CXX HOSTCC
	# export CFLAGS=""  # coreutils throws some sort of error if CFLAGS not set
	${EMERGE} --oneshot coreutils
	# perl workaround (to avoid user confirmation)
	${EMERGE} --oneshot perl < /dev/null
	${EMERGE} --oneshot findutils
	${EMERGE} --oneshot tar
	${EMERGE} --oneshot grep
	${EMERGE} --oneshot patch
	touch $@

install/stage2-gawk: install/stage2-up-to-patch
	# gawk-4.0.0 is buggy (2011-10-22)
	# XXX: has it been fixed?
	# echo "=sys-apps/gawk-4.0.0" >> ${EPREFIX}/etc/portage/package.mask/gawk-4.0.0
	# NOT NEEDED SINCE BOOTSTRAP HAS 3.1.8
	# THIS SHOULD MOVE AFTER -u system ? or right before stage4 -e
	${EMERGE} --oneshot gawk
	touch $@

#install/stage2-up-to-pax-utils: install/stage2-gawk
install/stage2-up-to-pax-utils: install/stage2-up-to-patch
	${EMERGE} --oneshot make
	${EMERGE} --oneshot --nodeps file
	${EMERGE} --oneshot --nodeps eselect
	${EMERGE} --oneshot pax-utils
	touch $@

install/stage2-portage-workarounds: install/stage2-up-to-pax-utils
	# XXX: THIS IS NEEDED !!??
	# python workaround
	# XXX: instead USE="-ssl -pam -berkdb" ?
	mkdir -p ${EPREFIX}/etc/portage/env/dev-lang/
	echo "export LDFLAGS='-L/usr/lib64'" >> ${EPREFIX}/etc/portage/env/dev-lang/python
	#LDFLAGS="-L/usr/lib64" ${EMERGE} --oneshot python
	# libxml2 workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/dev-libs
	#echo "export LDFLAGS=-l:\$$(ls ${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-libs/libxml2
	touch $@

install/stage2-portage: install/stage2-up-to-pax-utils install/stage2-portage-workarounds
#install/stage2-portage: install/stage2-up-to-pax-utils
	# Update portage
	env FEATURES="-collision-protect" ${EMERGE} --oneshot portage
	# Clean up tmp dir
	#-rm -Rf ${EPREFIX}/tmp/*
	-mv -f ${EPREFIX}/tmp ${EPREFIX}/tmp.old
	# Synchronize repo
	${EMERGE} --sync
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 3
# ----------------------------------------------------------------------------
install/stage3: install/stage2 install/stage3-workarounds
	# Update system
	${EMERGE} -u system
	touch $@

install/stage3-workarounds: install/stage2
	# git workaround
	USE="-git" ${EMERGE} --oneshot --nodeps gettext
	${EMERGE} --oneshot git
	# gcc workaround
	#echo 'sys-devel/gcc vanilla' >> ${EPREFIX}/etc/portage/package.use/gcc
	#${EMERGE} --oneshot -u "=gcc-4.2*"
	#gcc-config 2
	#source ${EPREFIX}/etc/profile
	# XXX: remove old one?
	# CLEAN_DELAY=0 ${EMERGE} -C "=gcc-4.2*"
	# KEEP THIS !!!
	# groff workaround
	mkdir -p ${EPREFIX}/etc/portage/env/sys-apps
	echo "export MAKEOPTS=-j1" > ${EPREFIX}/etc/portage/env/sys-apps/groff
	#MAKEOPTS=-j1 ${EMERGE} -u groff
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 4
# ----------------------------------------------------------------------------
install/stage4: install/stage3 install/stage4-config install/stage4-workarounds
	# -- recompile entire system
	#${EMERGE} -ve --jobs ${N_PROCESSORS} --load-average=${N_PROCESSORS} --with-bdeps y system world
	#${EMERGE} -ve --jobs ${N_PROCESSORS} system
	${EMERGE} -ve -j system
	# XXX: unset USE, etc?
	touch $@

install/stage4-config: install/stage3 make.conf
	# THIS IS NEEDED BUT REMOVE LOAD BALANCING
	# -- Update make.conf
	cp -vf make.conf ${EPREFIX}/etc/
	echo "MAKEOPTS=\"${MAKEOPTS}\"" >> ${EPREFIX}/etc/make.conf
	# -- python USE and MASK
	echo 'dev-lang/python sqlite wide-unicode berkdb' > ${EPREFIX}/etc/portage/package.use/python
	echo '>dev-lang/python-2.7.1-r1' > ${EPREFIX}/etc/portage/package.env/python-2.7.1-r1+
	touch $@

install/stage4-workarounds: install/stage3 install/stage4-config
	# XXX: DON'T USE THIS
	# -- gcc workaround
	#USE=-fortran ${EMERGE} -uDN gcc
	# Trying this:
	# $ rm -vf ${EPREFIX}/etc/portage/package.use/gcc
	# $ ${EMERGE} --nodeps -uN gcc
	# Next: gcc-config 2 && ${EMERGE} -C "=gcc-4.2*"
	#USE=-fortran ${EMERGE} --nodeps -uN gcc
	#gcc-config 2
	#source ${EPREFIX}/etc/profile
	# XXX: remove old one?
	# CLEAN_DELAY=0 ${EMERGE} -C "=gcc-4.2*"
	# -- mpc workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/dev-libs
	#echo "export LDFLAGS=-L${EPREFIX}/usr/lib" >> ${EPREFIX}/etc/portage/env/dev-libs/mpc
	#${EMERGE} mpc
	# -- openssh workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/net-misc
	#echo "export LDFLAGS=\"-l:${EPREFIX}/usr/lib/libssl.so -l:${EPREFIX}/usr/lib/libcrypto.so\"" >> ${EPREFIX}/etc/portage/env/net-misc/openssh
	#${EMERGE} openssh
	rm -f ${EPREFIX}/etc/portage/env/dev-lang/python
	touch $@

endif
