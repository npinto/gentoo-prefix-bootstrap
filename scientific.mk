ifndef SCIENTIFIC_MK
SCIENTIFIC_MK=scientific.mk

include init.mk
include tools.mk

scientific: tools bc gparallel ipython atlas numpy scipy matplotlib joblib \
	scikits.learn

# ----------------------------------------------------------------------------
bc:
	${EMERGE} -uN bc

gparallel:
	${EMERGE} -uN sys-process/parallel

pip:
	${EMERGE} -uN setuptools
	easy_install -U pip

ipython: pip
	${PIP} install -U ipython

atlas:
	${EMERGE} -uN cblas blas
	${EMERGE} -uN blas-atlas
	eselect blas set atlas-threads || exit 0
	eselect cblas set atlas-threads || exit 0
	${EMERGE} -uN lapack
	${EMERGE} -uN lapack-atlas
	eselect lapack set atlas || exit 0

numpy: atlas local-overlay
	echo "dev-python/numpy doc lapack test" >> ${EPREFIX}/etc/portage/package.use/numpy
	${EMERGE} -uN --onlydeps numpy
	FEATURES=test ${EMERGE} -uN numpy

scipy: numpy util-linux
	# -- arpack: workaround linking the wrong libgfortran
	mkdir -p ${EPREFIX}/etc/portage/env/sci-libs/
	echo "export LDFLAGS=\"-L$(shell echo $(shell dirname $(shell echo $(shell find ${EPREFIX}/usr/lib/ -name "libgfortran.so" | tail -n1))))\"" >> ${EPREFIX}/etc/portage/env/sci-libs/arpack
	#$LDFLAGS=-L$(shell echo $(shell dirname $(shell echo $(shell find /usr/lib/ -name "libfortran.so" | tail -n1)))) emerge -uN arpack
	emerge -uN arpack
	# -- superlu workaround
	#echo '>sci-libs/superlu-4.2' > ${EPREFIX}/etc/portage/package.mask/superlu-4.2+
	#echo '=sci-libs/superlu-4.3' >> ${EPREFIX}/etc/portage/package.unmask/scipy
	# XXX: scipy.test() still segfaults, due to superlu or atlas.
	# It might be related to gfortran/g77, see:
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/15541
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/4399
	#${EMERGE} -uN --onlydeps scipy
	#FEATURES=test ${EMERGE} -uN scipy
	${EMERGE} -uN scipy

matplotlib: numpy
	${EMERGE} -uN '=dev-python/python-dateutil-1.5'
	${EMERGE} -uN matplotlib

pycuda: pip
	${PIP} install -U pycuda

joblib: pip
	${PIP} install -U joblib

cython:
	emerge -uN dev-python/cython

scikits.learn: cython
	echo '=sci-libs/scikits-0.1 **' > ${EPREFIX}/etc/portage/package.keywords/scikits_learn
	echo '=sci-libs/libsvm-3.11 **' >> ${EPREFIX}/etc/portage/package.keywords/scikits_learn
	emerge -uN sci-libs/scikits_learn
	#${PIP} install -U scikits.learn

mongodb: local-overlay pip
	${EMERGE} -uN portage-utils
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy dev-db/mongodb
	echo "dev-db/mongodb v8" >> ${EPREFIX}/etc/portage/package.use/mongodb
	echo "dev-lang/v8 **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	echo "dev-db/mongodb **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	# mongodb workarounds
	-rm -vf ${EPREFIX}/etc/portage/env/dev-db/mongodb
	mkdir -p ${EPREFIX}/etc/portage/env/dev-db
	echo "export LDFLAGS=\"-L/usr/lib -L${EPREFIX}/usr/lib\"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXXFLAGS=\"-I/usr/include -I${EPREFIX}/usr/include \"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXX=${EPREFIX}/usr/bin/g++" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	${EMERGE} -uN mongodb
	${PIP} install -U pymongo
	# Useful aliases from:
	# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x
	# alias mongo-start="mongod --fork --dbpath \${EPREFIX}/var/lib/mongodb --logpath \${EPREFIX}/var/log/mongodb.log"
	# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
	# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

endif
