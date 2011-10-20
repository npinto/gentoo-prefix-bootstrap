#!/bin/bash

# ----------------------------------------------------------------------------
# Derived from:
# http://www.gentoo.org/proj/en/gentoo-alt/prefix/bootstrap-solaris.xml
# ----------------------------------------------------------------------------

source ./init.sh

# ----------------------------------------------------------------------------
# Backup previous installation
test -d $EPREFIX && mv -vf $EPREFIX{,-backup-$(date +"%Y-%m-%d_%Hh%Mm%Ss")}

# Grab latest bootstrap-prefix.sh
rm -f bootstrap-prefix.sh
wget -O bootstrap-prefix.sh http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt

# Patch to disable python crypt and nis modules
# For more info:
# * https://bugs.gentoo.org/show_bug.cgi?id=381163
# * http://archives.gentoo.org/gentoo-alt/msg_a1856438065eec550b5bf410488db9bb.xml
rm -f bootstrap-prefix-python-disable-crypt-nis.patch
wget https://raw.github.com/gist/1294750/d96a4b0f2be742dcca3adcb220a603b2260c4cc9/bootstrap-prefix-python-disable-crypt-nis.patch
patch -p0 < bootstrap-prefix-python-disable-crypt-nis.patch

# ----------------------------------------------------------------------------

chmod 755 bootstrap-prefix.sh
./bootstrap-prefix.sh $EPREFIX tree
./bootstrap-prefix.sh $EPREFIX/tmp make
./bootstrap-prefix.sh $EPREFIX/tmp wget
./bootstrap-prefix.sh $EPREFIX/tmp sed
./bootstrap-prefix.sh $EPREFIX/tmp coreutils6
./bootstrap-prefix.sh $EPREFIX/tmp findutils5
./bootstrap-prefix.sh $EPREFIX/tmp tar15
./bootstrap-prefix.sh $EPREFIX/tmp patch
./bootstrap-prefix.sh $EPREFIX/tmp grep
./bootstrap-prefix.sh $EPREFIX/tmp gawk
./bootstrap-prefix.sh $EPREFIX/tmp bash
./bootstrap-prefix.sh $EPREFIX/tmp zlib
./bootstrap-prefix.sh $EPREFIX/tmp python
./bootstrap-prefix.sh $EPREFIX/tmp bison
./bootstrap-prefix.sh $EPREFIX portage

hash -r

# ----------------------------------------------------------------------------

emerge --oneshot sed

emerge --oneshot --nodeps bash
emerge --oneshot --nodeps xz-utils
emerge --oneshot wget

emerge --oneshot --nodeps baselayout-prefix
emerge --oneshot --nodeps m4
emerge --oneshot --nodeps flex
emerge --oneshot --nodeps bison
emerge --oneshot --nodeps binutils-config
MAKEOPTS=-j1 emerge --oneshot --nodeps binutils
emerge --oneshot --nodeps gcc-config
emerge --oneshot --nodeps "=gcc-4.2*"

emerge --oneshot coreutils
emerge --oneshot findutils
emerge --oneshot tar
emerge --oneshot grep
emerge --oneshot patch
emerge --oneshot gawk
emerge --oneshot make
emerge --oneshot --nodeps file
emerge --oneshot --nodeps eselect
emerge --oneshot pax-utils

# -- Fixes:

# python dependencies
#emerge --oneshot sys-devel/autoconf
#emerge --oneshot app-admin/eselect-python
#emerge --oneshot app-arch/bzip2
#emerge --oneshot sys-libs/zlib
#emerge --oneshot virtual/libffi
#emerge --oneshot virtual/libintl
#emerge --oneshot sys-libs/db
#emerge --oneshot sys-libs/gdbm
#emerge --oneshot sys-libs/ncurses
#emerge --oneshot sys-libs/readline
#emerge --oneshot dev-db/sqlite
#emerge --oneshot dev-libs/openssl
#emerge --oneshot --nodeps dev-lang/tk # deps here???
#emerge --oneshot dev-tcltk/blt
#emerge --oneshot dev-libs/expat
#emerge --oneshot dev-util/pkgconfig
#emerge --oneshot sys-devel/libtool
#emerge --oneshot --nodeps app-admin/python-updater
#emerge --oneshot app-misc/mime-types
#emerge --oneshot dev-python/python-docs
#emerge --oneshot readline
#emerge --oneshot --onlydeps python
#libffi
# python
# XXX: or change /portage/env/dev-lang/python w/ LDFLAGS export
mkdir -p $EPREFIX/etc/portage/env/dev-lang/
echo "export LDFLAGS='-L/usr/lib64'" >> $EPREFIX/etc/portage/env/dev-lang/python
#
#LDFLAGS="-L/usr/lib64" emerge --oneshot --nodeps python
# is this nec?
#emerge --oneshot python


#ln -sf $EPREFIX/lib/libz.so{.1,}
#LDFLAGS="-L$EPREFIX/lib/" emerge libxml2
#emerge libxml2

# Update portage
env FEATURES="-collision-protect" emerge --oneshot portage
mkdir -p $EPREFIX/etc/portage/package.{keywords,use}

# Clean up tmp dir
rm -Rf $EPREFIX/tmp/*
hash -r

# Synchronize repo
emerge --sync

# Fix dependencies before 'emerge -u system'
USE="-git" emerge --oneshot gettext
emerge --oneshot git

echo 'sys-devel/gcc vanilla' >> $EPREFIX/etc/portage/package.use/gcc
emerge -u gcc
#gcc-config 2
#source $EPREFIX/etc/profile
MAKEOPTS=-j1 emerge -u groff

emerge -u system

# -- New (global) options: USE, MAKEOPTS, etc.
cp -vf $(dirname $0)/make.conf $EPREFIX/etc/
echo "MAKEOPTS=\"-j$((${N_PROCESSORS}+1))\"" >> $EPREFIX/etc/make.conf

# -- Update package-dependent USE
echo 'dev-lang/python sqlite wide-unicode berkdb' >> $EPREFIX/etc/portage/package.use/python

# -- Update gcc
USE=-fortran emerge -uDN gcc
#gcc-config 2
#source $EPREFIX/etc/profile

# -- Final system installation
emerge -e -j system
emerge -e -j world

echo "DONE!"

