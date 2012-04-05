ifndef STAGE2_MK
STAGE2_MK=stage2.mk

include init.mk

install/stage2: install/stage1 install/stage2-up-to-bison \
	install/stage2-binutils install/stage2-gcc \
	install/stage2-up-to-pax-utils install/stage2-portage
	touch $@

install/_stage2-sed:
	${EMERGE} --oneshot -j sys-apps/sed
	touch $@

install/_stage2-bash:
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps app-shells/bash
	touch $@

install/_stage2-xz-utils:
	${EMERGE} --oneshot --nodeps app-arch/xz-utils
	touch $@

install/_stage2-automake:
	${EMERGE} --oneshot -j sys-devel/automake
	touch $@

install/_stage2-tar:
	${EMERGE} --oneshot --nodeps app-arch/tar
	touch $@

install/_stage2-file:
	${EMERGE} --oneshot --nodeps sys-apps/file
	touch $@

install/_stage2-pkgconfig:
	${EMERGE} --oneshot -j dev-util/pkgconfig
	touch $@

install/_stage2-wget:
	${EMERGE} --oneshot -j net-misc/wget
	touch $@

install/_stage2-baselayout-prefix:
	${EMERGE} --oneshot --nodeps sys-apps/baselayout-prefix
	touch $@

#install/_stage2-m4:
	#${EMERGE} --oneshot --nodeps sys-devel/m4
	#touch $@

install/_stage2-flex:
	${EMERGE} --oneshot --nodeps sys-devel/flex
	touch $@

install/_stage2-bison:
	${EMERGE} --oneshot --nodeps sys-devel/bison
	touch $@

install/stage2-up-to-bison: install/stage1 \
	install/_stage2-sed \
	install/_stage2-bash \
	install/_stage2-xz-utils \
	install/_stage2-automake \
	install/_stage2-tar \
	install/_stage2-file \
	install/_stage2-pkgconfig \
	install/_stage2-wget \
	install/_stage2-baselayout-prefix \
	#install/_stage2-m4 \
	install/_stage2-flex \
	install/_stage2-bison
	touch $@

install/stage2-binutils: install/stage2-up-to-bison
	# emerge --oneshot --nodeps "<sys-devel/binutils-2.22"
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
	${EMERGE} --oneshot -j sys-devel/bison
	${EMERGE} --oneshot --nodeps "=sys-devel/gcc-4.2*"
	echo ">sys-devel/gcc-4.2" > ${EPREFIX}/etc/portage/package.mask/gcc
	touch $@

install/stage2-up-to-pax-utils: install/stage2-gcc
	${EMERGE} --oneshot coreutils
	# -- perl: workaround to avoid user confirmation
	${EMERGE} --oneshot perl < /dev/null
	${EMERGE} --oneshot -j findutils
	${EMERGE} --oneshot -j sys-devel/automake
	${EMERGE} --oneshot -j app-arch/tar
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
	${EMERGE} --oneshot -j sys-libs/readline
	#${EMERGE} --nodeps dev-lang/python
	${EMERGE} -j dev-lang/python
	touch $@

install/stage2-portage: install/stage2-up-to-pax-utils install/stage2-portage-workarounds
	# -- Update portage
	env FEATURES="-collision-protect" ${EMERGE} --oneshot sys-apps/portage
	# -- Move tmp directory
	#-mv -f ${EPREFIX}/tmp ${EPREFIX}/tmp.old
	# -- Synchronize repo
	${EMERGE} --sync
	touch $@

endif
