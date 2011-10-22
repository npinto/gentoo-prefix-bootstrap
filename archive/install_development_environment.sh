#!/bin/bash

source ./init.sh

# ----------------------------------------------------------------------------
emerge zsh
emerge tmux
emerge ncdu
emerge htop

# -- gnu parallel
(cd $EPREFIX/usr/local/portage && $EPREFIX/usr/portage/scripts/ecopy sys-process/parallel)
emerge sys-process/parallel

# -- blas/atlas
emerge -u cblas lapack blas
emerge -u {blas,lapack}-atlas
eselect blas set atlas-threads
eselect cblas set atlas-threads
eselect lapack set atlas

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


