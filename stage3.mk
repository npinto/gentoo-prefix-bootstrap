ifndef STAGE3_MK
STAGE3_MK=stage3.mk

include init.mk

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

endif
