ifndef STAGE1_MK
STAGE1_MK=stage1.mk

include init.mk

stage1: install/stage1
install/stage1: install/stage0 \
	install/_stage1-tree \
	install/_stage1-make \
	install/_stage1-wget \
	install/_stage1-sed \
	install/_stage1-coreutils \
	install/_stage1-findutils \
	install/_stage1-tar \
	install/_stage1-patch \
	install/_stage1-grep \
	install/_stage1-gawk \
	install/_stage1-zlib \
	install/_stage1-python \
	install/_stage1-m4 \
	install/_stage1-bison \
	install/_stage1-bash \
	install/_stage1-portage
	touch $@

install/_stage1-tree:
	#./bootstrap-prefix.sh ${EPREFIX} latest_tree
	./bootstrap-prefix.sh ${EPREFIX} tree
	cp -vaf files/usr/portage/app-admin/python-updater/* ${EPREFIX}/usr/portage/app-admin/python-updater/
	rm -vf ${EPREFIX}/usr/portage/app-admin/python-updater/python-updater-0.9*.ebuild
	touch $@

install/_stage1-make:
	./bootstrap-prefix.sh ${EPREFIX}/tmp make
	touch $@

install/_stage1-wget:
	./bootstrap-prefix.sh ${EPREFIX}/tmp wget
	touch $@

install/_stage1-sed:
	./bootstrap-prefix.sh ${EPREFIX}/tmp sed
	touch $@

install/_stage1-coreutils:
	./bootstrap-prefix.sh ${EPREFIX}/tmp coreutils
	touch $@

install/_stage1-findutils:
	./bootstrap-prefix.sh ${EPREFIX}/tmp findutils
	touch $@

install/_stage1-tar:
	./bootstrap-prefix.sh ${EPREFIX}/tmp tar
	touch $@

install/_stage1-patch:
	./bootstrap-prefix.sh ${EPREFIX}/tmp patch
	touch $@

install/_stage1-grep:
	./bootstrap-prefix.sh ${EPREFIX}/tmp grep
	touch $@

install/_stage1-gawk:
	./bootstrap-prefix.sh ${EPREFIX}/tmp gawk
	touch $@

install/_stage1-zlib:
	./bootstrap-prefix.sh ${EPREFIX}/tmp zlib
	touch $@

install/_stage1-python:
	./bootstrap-prefix.sh ${EPREFIX}/tmp python
	touch $@

install/_stage1-m4:
	./bootstrap-prefix.sh ${EPREFIX}/tmp m4
	touch $@

install/_stage1-bison:
	./bootstrap-prefix.sh ${EPREFIX}/tmp bison
	touch $@

install/_stage1-bash:
	MAKEOPTS=-j1 ./bootstrap-prefix.sh ${EPREFIX}/tmp bash
	touch $@

install/_stage1-portage:
	./bootstrap-prefix.sh ${EPREFIX} portage
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	mkdir -p ${EPREFIX}/etc/portage/package.unmask
	mkdir -p ${EPREFIX}/etc/portage/package.env
	mkdir -p ${EPREFIX}/etc/portage/env
	touch $@

endif
