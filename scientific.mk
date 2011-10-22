include init.mk
include tools.mk

# ============================================================================
# == install_scientific
# ============================================================================

default: install_scientific

# ----------------------------------------------------------------------------
install_scientific: eix gparallel atlas

gparallel:
	cd ${EPREFIX}/usr/local/portage
	${EPREFIX}/usr/portage/scripts/ecopy sys-process/parallel
	emerge -uDN sys-process/parallel

atlas:
	emerge -uDN cblas lapack blas
	emerge -uDN blas-atlas lapack-atlas
	eselect blas set atlas-threads || exit 0
	eselect cblas set atlas-threads || exit 0
	eselect lapack set atlas || exit 0

rest:
	# -- numpy
	echo "dev-python/numpy doc lapack test" >> $EPREFIX/etc/portage/package.use/numpy
	emerge -uDN numpy

	# -- scipy
	#emerge -uDN umfpack
	#echo "sci-libs/scipy doc umfpack" >> $EPREFIX/etc/portage/package.use/scipy

	# work around the temporary kernel.org outtage
	cp -vf $(dirname $0)/util-linux-2.17.ebuild $EPREFIX/usr/portage/sys-apps/util-linux/
	ebuild $EPREFIX/usr/portage/sys-apps/util-linux/util-linux-2.17.ebuild manifest
	emerge --oneshot --nodeps util-linux

	emerge -uDN scipy

	# -- XXX
	easy_install -U pip

	pip install -vUI ipython

	pip install -vUI pycuda

	pip install -vUI joblib

	pip install -vUI scikits.learn


