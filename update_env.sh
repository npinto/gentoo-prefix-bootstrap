#!/bin/bash

export N_PROCESSORS=$(cat /proc/cpuinfo  | grep processor | wc -l)
export MAKEOPTS="-j $(($N_PROCESSORS+1))"

REAL_HOME=$(readlink -f ${HOME})

test -z ${EPREFIX} && EPREFIX=${REAL_HOME}/gentoo
set -x
export EPREFIX
echo ${EPREFIX}
export PATH=${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX}/tmp/usr/bin:${EPREFIX}/tmp/bin:${PATH}
set +x
