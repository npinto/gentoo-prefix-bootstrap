ifndef SCIENTIFIC_MK
SCIENTIFIC_MK=scientific.mk

include init.mk
include tools.mk

scientific: eix bc gparallel atlas numpy scientific rest

# ----------------------------------------------------------------------------
tmppp:
	echo ${EPREFIX}

bc:
	emerge -uDN bc

gparallel:
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy sys-process/parallel
	emerge -uDN sys-process/parallel

atlas:
	emerge -uDN cblas lapack blas
	emerge -uDN blas-atlas lapack-atlas
	eselect blas set atlas-threads || exit 0
	eselect cblas set atlas-threads || exit 0
	eselect lapack set atlas || exit 0

numpy: atlas
	echo "=dev-python/numpy-1.6.1-r1" >> ${EPREFIX}/etc/portage/package.mask/numpy-1.6.1-r1
	echo "dev-python/numpy doc lapack test" >> ${EPREFIX}/etc/portage/package.use/numpy
	#emerge -u sqlite
	emerge -uDN --onlydeps numpy
	FEATURES=test emerge -uN numpy

scipy: numpy
	#emerge -uDN umfpack
	#echo "sci-libs/scipy doc umfpack" >> ${EPREFIX}/etc/portage/package.use/scipy
	# util-linux work around
	# the temporary kernel.org outtage
	echo "=sys-apps/util-linux-2.18-r1 **" >> ${EPREFIX}/etc/portage/package.keywords/util-linux
	#mkdir -p ${EPREFIX}/usr/local/portage/sys-apps/util-linux/
	#cp -vf util-linux-2.17.ebuild ${EPREFIX}/usr/local/portage/sys-apps/util-linux/
	#ebuild ${EPREFIX}/usr/portage/sys-apps/util-linux/util-linux-2.17.ebuild manifest
	emerge --oneshot --nodeps util-linux
	# XXX: scipy.test() still segfaults, due to superlu or atlas.
	# It might be related to gfortran/g77, see:
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/15541
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/4399
	emerge -uDN --onlydeps scipy
	#FEATURES=test emerge -uN scipy
	emerge -uN scipy

mongodb:
	echo ${EPREFIX}
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy dev-db/mongodb
	echo "dev-db/mongodb v8" >> ${EPREFIX}/etc/portage/package.use/mongodb
	echo "dev-lang/v8 **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	echo "dev-db/mongodb **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	# mongodb workarounds
	-rm -vf ${EPREFIX}/etc/portage/env/dev-db/mongodb
	mkdir -p ${EPREFIX}/etc/portage/env/dev-db
	echo "export LDFLAGS=\"-L/usr/lib -L${EPREFIX}/usr/lib\"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXXFLAGS=\"-I/usr/include -I${EPREFIX}/usr/include \"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXX=g++" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	emerge -v mongodb
	# Useful aliases from:
	# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x
	# alias mongo-start="mongod --fork --dbpath \${EPREFIX}/var/lib/mongodb --logpath \${EPREFIX}/var/log/mongodb.log"
	# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
	# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

rest:
	easy_install -U pip
	pip install -vUI ipython
	pip install -vUI pycuda
	pip install -vUI joblib
	pip install -vUI scikits.learn

endif
