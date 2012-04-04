ifndef SYSTEM_MK
SYSTEM_MK=system.mk

include init.mk

system: \
	install/stage0 \
	install/stage1 \
	install/stage2 \
	install/stage3 \
	install/stage4

# ----------------------------------------------------------------------------
# -- STAGE 0
# ----------------------------------------------------------------------------
install/stage0: bootstrap-prefix.sh
	mkdir -p install
	touch $@

bootstrap-prefix.sh:
	wget -O bootstrap-prefix.sh http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt
	chmod 755 bootstrap-prefix.sh

# ----------------------------------------------------------------------------
# -- install/stage 1
# ----------------------------------------------------------------------------
install/stage1: install/stage0
	./bootstrap-prefix.sh ${EPREFIX} tree
	./bootstrap-prefix.sh ${EPREFIX}/tmp make
	./bootstrap-prefix.sh ${EPREFIX}/tmp wget
	./bootstrap-prefix.sh ${EPREFIX}/tmp sed
	./bootstrap-prefix.sh ${EPREFIX}/tmp coreutils
	./bootstrap-prefix.sh ${EPREFIX}/tmp findutils
	./bootstrap-prefix.sh ${EPREFIX}/tmp tar15
	./bootstrap-prefix.sh ${EPREFIX}/tmp patch
	./bootstrap-prefix.sh ${EPREFIX}/tmp grep
	./bootstrap-prefix.sh ${EPREFIX}/tmp gawk
	./bootstrap-prefix.sh ${EPREFIX}/tmp zlib
	./bootstrap-prefix.sh ${EPREFIX}/tmp python
	./bootstrap-prefix.sh ${EPREFIX}/tmp m4
	./bootstrap-prefix.sh ${EPREFIX}/tmp bison
	./bootstrap-prefix.sh ${EPREFIX}/tmp bash
	./bootstrap-prefix.sh ${EPREFIX} portage
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	mkdir -p ${EPREFIX}/etc/portage/package.unmask
	mkdir -p ${EPREFIX}/etc/portage/package.env
	mkdir -p ${EPREFIX}/etc/portage/env
	touch $@

# ----------------------------------------------------------------------------
# -- STAGE 2
# ----------------------------------------------------------------------------
install/stage2: install/stage1 install/stage2-up-to-bison \
	install/stage2-binutils install/stage2-gcc \
	install/stage2-up-to-pax-utils install/stage2-portage
	touch $@

install/stage2-up-to-bison: install/stage1
	${EMERGE} --oneshot sys-apps/sed
	${EMERGE} --oneshot --nodeps app-shells/bash
	${EMERGE} --oneshot --nodeps app-arch/xz-utils
	${EMERGE} --oneshot --nodeps app-arch/tar
	${EMERGE} --oneshot --nodeps sys-apps/file
	${EMERGE} --oneshot dev-util/pkgconfig
	${EMERGE} --oneshot net-misc/wget
	${EMERGE} --oneshot --nodeps sys-apps/baselayout-prefix
	${EMERGE} --oneshot --nodeps sys-devel/m4
	${EMERGE} --oneshot --nodeps sys-devel/flex
	${EMERGE} --oneshot --nodeps sys-devel/bison
	touch $@

install/stage2-binutils: install/stage2-up-to-bison
	${EMERGE} --oneshot --nodeps sys-devel/binutils-config
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps sys-devel/binutils \
		|| \
		MAKEOPTS=-j1 ebuild --skip-manifest \
		${EPREFIX}/usr/portage/sys-devel/binutils/binutils-2.20.1-r1.ebuild \
		clean merge
	touch $@

install/stage2-gcc: install/stage2-binutils
	${EMERGE} --oneshot --nodeps sys-devel/gcc-config
	# XXX: get the right kernel version?
	${EMERGE} --oneshot --nodeps sys-kernel/linux-headers
	${EMERGE} --oneshot --nodeps "=sys-devel/gcc-4.2.4-r01.4"
	echo ">sys-devel/gcc-4.2.4-r01.4" > ${EPREFIX}/etc/portage/package.mask/gcc-4.2.4-r01.4+
	touch $@

install/stage2-up-to-pax-utils: install/stage2-gcc
	${EMERGE} --oneshot coreutils
	# -- perl: workaround to avoid user confirmation
	${EMERGE} --oneshot perl < /dev/null
	${EMERGE} --oneshot findutils
	${EMERGE} --oneshot app-arch/tar
	${EMERGE} --oneshot grep
	${EMERGE} --oneshot patch
	${EMERGE} --oneshot gawk
	${EMERGE} --oneshot make
	${EMERGE} --oneshot --nodeps file
	${EMERGE} --oneshot --nodeps eselect
	${EMERGE} --oneshot pax-utils
	touch $@

install/stage2-portage-workarounds: install/stage2-up-to-pax-utils
	# -- python: workarounds (only for stage2)
	mkdir -p ${EPREFIX}/etc/portage/env/dev-lang/
	echo "export LDFLAGS='-L/usr/lib64'" > ${EPREFIX}/etc/portage/env/dev-lang/python
	# --
	${EMERGE} --oneshot sys-libs/readline
	${EMERGE} --nodeps dev-lang/python
	touch $@

install/stage2-portage: install/stage2-up-to-pax-utils install/stage2-portage-workarounds
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
install/stage3: install/stage2 install/stage3-workarounds
	# -- Update system
	${EMERGE} -u -j system
	touch $@

install/stage3-workarounds: install/stage2
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
install/stage4: install/stage3 install/stage4-config install/stage4-workarounds
	# -- Recompile entire system
	${EMERGE} -ve -j system
	# -- cleaning up some workarounds
	CLEAN_DELAY=0 ${EMERGE} -C linux-headers
	# -- startprefix
	cd ${EPREFIX}/usr/portage/scripts && ./bootstrap-prefix.sh ${EPREFIX} startscript
	sed -i ${EPREFIX}/startprefix -e 's/^EPREFIX=/export EPREFIX=/g'
	# -- purge news
	eselect news purge
	touch $@

install/stage4-config: install/stage3 files/make.conf
	# -- Update make.conf
	cp -vf files/make.conf ${EPREFIX}/etc/
	echo "MAKEOPTS=\"${MAKEOPTS}\"" >> ${EPREFIX}/etc/make.conf
	# -- python: update USE and mask >python-2.7.1-r1 to avoid this bug:
	# http://bugs.python.org/issue9762
	echo 'dev-lang/python sqlite wide-unicode berkdb' > ${EPREFIX}/etc/portage/package.use/python
	echo '>dev-lang/python-2.7.1-r1' > ${EPREFIX}/etc/portage/package.mask/python-2.7.1-r1+
	touch $@

install/stage4-workarounds: install/stage3 install/stage4-config
	# -- python: remove stage2 workaround
	rm -f ${EPREFIX}/etc/portage/env/dev-lang/python
	${EMERGE} python
	# -- net-tools: workaround
	${EMERGE} --oneshot --nodeps linux-headers
	touch $@
endif
