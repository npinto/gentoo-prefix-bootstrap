
default: install/stage1 install/stage2-up-to-bison install/stage2-gcc-ubuntu \
	install/stage2-portage-ubuntu  install/stage3-ubuntu install/stage4-ubuntu

include init.mk
include system.mk

# XXX: tar22?
# XXX: texinfo -j1
#
install/stage2-gcc-ubuntu:
	emerge --nodeps --oneshot binutils
	emerge --nodeps --oneshot gcc-config
	emerge --nodeps app-arch/tar
	LIBRARY_PATH="${EPREFIX}/usr/lib:$(shell echo $(shell dirname $(shell echo $(shell find /usr/lib/ -name "libc.so" | tail -n1))))" INCLUDE_PATH="${EPREFIX}/usr/include:$(shell echo $(shell dirname $(shell echo $(shell find /usr/include/ -name 'errno.h' | grep -e '/asm/errno.h' | tail -n1))))/../" emerge --oneshot --nodeps "=gcc-4.2*"
	touch install/stage2-binutils
	touch install/stage2-gcc
	touch $@

install/stage2-up-to-pax-utils-ubuntu: install/stage2-gcc-ubuntu
	# -- perl: workaround to avoid user confirmation
	#${EMERGE} --oneshot perl < /dev/null
	${EMERGE} --oneshot coreutils
	${EMERGE} --oneshot findutils
	${EMERGE} --oneshot tar
	${EMERGE} --oneshot grep
	${EMERGE} --oneshot patch
	${EMERGE} --oneshot gawk
	${EMERGE} --oneshot make
	${EMERGE} --oneshot --nodeps file
	${EMERGE} --oneshot --nodeps eselect
	${EMERGE} --oneshot pax-utils
	touch $@

install/stage2-portage-workarounds-ubuntu: install/stage2-up-to-pax-utils-ubuntu
	# -- python: workaround (only for stage2)
	mkdir -p ${EPREFIX}/etc/portage/env/dev-lang/
	echo "export LDFLAGS='-L/usr/lib64'" > ${EPREFIX}/etc/portage/env/dev-lang/python
	# -- libtool: workaround (especialy for Ubuntu 10+)
	emerge --nodeps --oneshot libtool
	# -- texinfo: workaround help2man dependency
	touch $@

install/stage2-portage-ubuntu: install/stage2-up-to-pax-utils-ubuntu install/stage2-portage-workarounds-ubuntu
	# -- Update portage
	env FEATURES="-collision-protect" ${EMERGE} --oneshot portage
	# -- Move tmp directory
	-mv -f ${EPREFIX}/tmp ${EPREFIX}/tmp.old
	# -- Synchronize repo
	${EMERGE} --sync
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 3
# ----------------------------------------------------------------------------
install/stage3-ubuntu: 
	#install/stage2-ubuntu install/stage3-workarounds-ubuntu
	# -- Update system
	${EMERGE} -u -j system
	touch $@

install/stage3-workarounds-ubuntu: install/stage2-ubuntu
	# -- git: workaround
	USE="-git" ${EMERGE} --oneshot --nodeps gettext
	${EMERGE} --oneshot git
	# -- groff: workaround
	mkdir -p ${EPREFIX}/etc/portage/env/sys-apps
	echo "export MAKEOPTS=-j1" > ${EPREFIX}/etc/portage/env/sys-apps/groff
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 4
# ----------------------------------------------------------------------------
install/stage4-ubuntu: install/stage3-ubuntu install/stage4-config-ubuntu \
	install/stage4-workarounds-ubuntu
	# -- Recompile entire system
	${EMERGE} -ve -j system
	touch $@

install/stage4-config-ubuntu: install/stage3-ubuntu make.conf
	# -- Update make.conf
	cp -vf make.conf ${EPREFIX}/etc/
	echo "MAKEOPTS=\"${MAKEOPTS}\"" >> ${EPREFIX}/etc/make.conf
	# -- python: update USE and mask >python-2.7.1-r1 to avoid this bug:
	# http://bugs.python.org/issue9762
	echo 'dev-lang/python sqlite wide-unicode berkdb' > ${EPREFIX}/etc/portage/package.use/python
	echo '>dev-lang/python-2.7.1-r1' > ${EPREFIX}/etc/portage/package.mask/python-2.7.1-r1+
	touch $@

install/stage4-workarounds-ubuntu: install/stage3-ubuntu install/stage4-config-ubuntu
	# -- python: remove stage2 workaround
	rm -f ${EPREFIX}/etc/portage/env/dev-lang/python
	${EMERGE} python
	# -- gcc: workaround (reinstall?)
	touch $@

