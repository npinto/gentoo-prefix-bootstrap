#!/bin/bash

set -x
set -e

source ./update_env.sh
. ./update_env.sh

make uninstall-force
make install/stage1
make install/stage2-up-to-bison

# make -n install/stage2
#emerge --nodeps tar

#ACCEPT_KEYWORDS="**" emerge --nodeps "=app-arch/tar-1.23*"
cp -vf files/local_overlay/tar/tar-1.23-r4.ebuild ${EPREFIX}/usr/portage/app-arch/tar/
ebuild ${EPREFIX}/usr/portage/app-arch/tar/tar-1.23-r4.ebuild manifest
emerge --nodeps "=app-arch/tar-1.23*"

mkdir -p files/local_overlay
cp -a ${EPREFIX}/usr/portage/app-arch/tar files/local_overlay/

LIBRARY_PATH=/usr/lib/x86_64-linux-gnu  emerge --nodeps --oneshot binutils '=gcc-4.2*'

