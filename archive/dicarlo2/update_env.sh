#!/bin/bash

export N_PROCESSORS=$(cat /proc/cpuinfo  | grep processor | wc -l)
export MAKEOPTS="-j $(($N_PROCESSORS+1))"

export EPREFIX=$HOME/gentoo
export PATH=$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:$PATH
#export CHOST="x86_64-apple-darwin10"
