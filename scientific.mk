ifndef SCIENTIFIC_MK
SCIENTIFIC_MK=scientific.mk

include init.mk
include tools.mk

scientific: eix bc gparallel atlas numpy scipy ipython mongodb

# ----------------------------------------------------------------------------
bc:
	emerge -uDN bc

gparallel:
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy sys-process/parallel
	emerge -uDN sys-process/parallel

atlas:
	#emerge -uDN cblas blas
	emerge -uDN blas-atlas
	eselect blas set atlas-threads || exit 0
	eselect cblas set atlas-threads || exit 0
	#emerge -uDN lapack
	emerge -uDN lapack-atlas
	eselect lapack set atlas || exit 0

numpy: atlas
	#echo "=dev-python/numpy-1.6.1-r1" >> ${EPREFIX}/etc/portage/package.mask/numpy-1.6.1-r1
	echo "dev-python/numpy doc lapack test" >> ${EPREFIX}/etc/portage/package.use/numpy
	#emerge -u sqlite
	#emerge -uDN --onlydeps numpy
	#FEATURES=test emerge -uN numpy
	emerge -uDN numpy
	python -c 'import numpy as np; np.test(verbose=2)'

scipy: numpy util-linux
	#emerge -uDN umfpack
	#echo "sci-libs/scipy doc umfpack" >> ${EPREFIX}/etc/portage/package.use/scipy
	# XXX: scipy.test() still segfaults, due to superlu or atlas.
	# It might be related to gfortran/g77, see:
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/15541
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/4399
	#emerge -uDN --onlydeps scipy
	#FEATURES=test emerge -uN scipy
	emerge -uDN scipy

matplotlib: numpy
	emerge -uDN matplotlib

pip:
	emerge -uDN setuptools
	easy_install -U pip

ipython: pip
	pip install -vUI ipython

pycuda: pip
	pip install -vUI pycuda

joblib: pip
	pip install -vUI joblib

scikits.learn: pip
	pip install -vUI scikits.learn

mongodb: local-overlay pip
	emerge -uDN portage-utils
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
	emerge -uDN mongodb
	pip install -vUI pymongo
	# Useful aliases from:
	# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x
	# alias mongo-start="mongod --fork --dbpath \${EPREFIX}/var/lib/mongodb --logpath \${EPREFIX}/var/log/mongodb.log"
	# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
	# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

endif
