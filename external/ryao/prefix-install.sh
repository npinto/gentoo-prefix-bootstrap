#!/usr/bin/env bash

# Copyright (c) 2012, Richard Yao ryao@cs.stonybrook.edu

# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# prefix-install.sh
#	A script for bootstrapping Gentoo Prefix on Linux and Solaris systems
#	Based on Gentoo Prefix Bootstrap Process for Solaris

#	See the actual guide before using this script:
#	http://www.gentoo.org/proj/en/gentoo-alt/prefix/bootstrap-solaris.xml

# Settings a user should configure include:
#	CHOST		The system CHOST
#	EPREFIX		Where the installation goes
#	MAKEOPTS	Make options
#	UMASK		The umask value to use for the installation

# Settings available to advanced users include:
#	FEATURES	Portage FEATURES options
#	ESYS_OPTS	Emerge options for compiling @system
#	CFLAGS		C Compiler Flags for compiling @system
#	CXXFLAGS	C++ Compiler Flags for compiling @system
#	FFLAGS		FORTRAN 77 Compiler Flags for compiling @system
#	FCFLAGS		FORTRAN 90/95 Compiler Flags for compiling @system
#	LDFLAGS		Linker Flags for building @system
#	USE		USE flags for @system cbuild

# Additional packages can be included in the initial install by providing their
# atoms as commandline arguments
#	e.g. ./prefix-install app-portage/genlop app-misc/screen

# A reasonable way to invoke this script when installing Gentoo Prefix for all
# users on a amd64 quadcore system is to do the following:
#	env CHOST=x86_64-pc-linux-gnu EPREFIX=/usr/local/gentoo MAKEOPTS=-j5 UMASK=022 ./prefix-install.sh

# Known Requirements
#	bash
#	wget
#	Basic UNIX utilities (i.e. chmod, rm, cat, env)


set -e
umask ${UMASK:-"077"}

FEATURES=${FEATURES:-"parallel-fetch parallel-install"}

SAVED_CFLAGS=${CFLAGS:-'-O2 -pipe'}
SAVED_CXXFLAGS=${CXXFLAGS:-'${CFLAGS}'}
SAVED_FCFLAGS=${CFLAGS:-'${CFLAGS}'}
SAVED_FFLAGS=${CXXFLAGS:-'${CFLAGS}'}
SAVED_LDFLAGS=${LDFLAGS:-'${LDFLAGS}'}
SAVED_USE=${USE='unicode nls'}
unset CFLAGS CXXFLAGS LDFLAGS USE

# Code Listing 1.1: Export EPREFIX variable
EPREFIX=${EPREFIX:-"$HOME/gentoo"}
EPREFIX_TMP=${EPREFIX_TMP:-"${EPREFIX}/tmp"}

# Code Listing 1.2: Add Prefix and utility paths to your PATH on Solaris 10/x86
PATH="${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX_TMP}/usr/bin:${EPREFIX_TMP}/bin:/usr/sfw/bin:/usr/sfw/i386-sun-solaris2.10/bin:/usr/sfw/sparc-sun-solaris2.10/bin:/usr/bin:/bin"

# Setup ./bootstrap-prefix
if [ ! -f ./bootstrap-prefix.sh ]
then
  rm -f ./bootstrap-prefix.sh
  wget -O ./bootstrap-prefix.sh "http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt"
  chmod u+x ./bootstrap-prefix.sh
fi

# Set CHOST
if [ -z "${CHOST}" ]
then
	CHOST="$(./bootstrap-prefix.sh chost.guess ${EPREFIX} 2> /dev/null)"

	# Prefer 64-bit if available
	case ${CHOST} in
	i386-apple-darwin*)
		[ "$(/usr/sbin/sysctl -n hw.cpu64bit_capable)" == "1" ] && export CHOST="x86_64-${CHOST#*-}"
		;;
	sparc-sun-solaris*)
		isa="$(isainfo -kv)"
		[ "${isa%-bit*}" == "64" ] && export CHOST="sparcv9-${CHOST#*-}"
		unset isa
		;;
	esac

fi

# Code Listing 1.3: Use the bootstrap script
./bootstrap-prefix.sh "${EPREFIX}" tree
./bootstrap-prefix.sh "${EPREFIX_TMP}" make
./bootstrap-prefix.sh "${EPREFIX_TMP}" wget
./bootstrap-prefix.sh "${EPREFIX_TMP}" sed
./bootstrap-prefix.sh "${EPREFIX_TMP}" coreutils8 # Workaround Linux failure without breaking Solaris Compatibility
./bootstrap-prefix.sh "${EPREFIX_TMP}" findutils5
env FORCE_UNSAFE_CONFIGURE=1 ./bootstrap-prefix.sh "${EPREFIX_TMP}" tar26 # root failure workaround; thanks vortexx
./bootstrap-prefix.sh "${EPREFIX_TMP}" patch9 #Workaround for Mac OS X
./bootstrap-prefix.sh "${EPREFIX_TMP}" grep
./bootstrap-prefix.sh "${EPREFIX_TMP}" gawk
env MAKEOPTS=-j1 ./bootstrap-prefix.sh "${EPREFIX_TMP}" bash # Workaround race condition
./bootstrap-prefix.sh "${EPREFIX_TMP}" zlib
./bootstrap-prefix.sh "${EPREFIX_TMP}" python
./bootstrap-prefix.sh "${EPREFIX}" portage

# Code Listing 1.4: rehash in bash
hash -r

case ${CHOST} in
powerpc64-*-linux*)
	mkdir -p "$EPREFIX/etc/portage"
	echo "=dev-vcs/git-9999" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=dev-vcs/mercurial-9999" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=sys-devel/gnuconfig-99999999" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=dev-libs/libffi-3.0.11_rc2" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=dev-lang/python-3.2" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=sys-libs/ncurses-5.9-r1" >> "${EPREFIX}/etc/portage/package.mask"
	echo "=sys-apps/util-linux-2.20.1" >> "${EPREFIX}/etc/portage/package.mask"
	;;
esac

# Code Listing 1.5: emerge sed
emerge --oneshot sed

# Code Listing 1.6: emerge bash, wget
env MAKEOPTS=-j1 emerge --oneshot --nodeps bash # Workaround for bash race condition when MAKEOPTS=-j65
emerge --oneshot app-misc/pax-utils

# Code Listing 1.7: emerge linker and compiler
emerge --oneshot --nodeps sys-apps/baselayout-prefix
emerge --oneshot --nodeps app-arch/xz-utils
emerge --oneshot --nodeps sys-devel/m4
emerge --oneshot --nodeps sys-devel/flex
emerge --oneshot --nodeps sys-devel/bison
emerge --oneshot --nodeps sys-devel/binutils-config
if [ "`uname -s`" = "Darwin" ]
then
	case "$(readlink `which cc`)" in
	gcc-4.0*)
		emerge --oneshot --nodeps sys-devel/binutils-apple-3.2
		;;
	*)
		emerge --oneshot --nodeps sys-devel/binutils-apple
	esac
	emerge --oneshot --nodeps sys-devel/gcc-config
	emerge --oneshot --nodeps sys-devel/gcc-apple
else
	# Workaround for broken =sys-devel/binutils-2.22
	emerge --oneshot --nodeps "<sys-devel/binutils-2.22"
	emerge --oneshot --nodeps sys-devel/gcc-config
	emerge --oneshot --nodeps "=sys-devel/gcc-4.2*"
fi

# Code Listing 1.8: emerge several tools
emerge --oneshot sys-apps/coreutils
emerge --oneshot sys-apps/findutils
emerge --oneshot app-arch/tar
emerge --oneshot sys-apps/grep
emerge --oneshot sys-devel/patch
emerge --oneshot sys-apps/gawk
emerge --oneshot sys-devel/make
emerge --oneshot sys-libs/zlib
emerge --oneshot --nodeps sys-apps/file
emerge --oneshot --nodeps app-admin/eselect
emerge --oneshot "<net-misc/wget-1.13.4-r1"

# Code Listing 1.9: emerge portage
env FEATURES="-collision-protect" emerge --oneshot sys-apps/portage

# Code Listing 1.10: remove tmp directory
rm -Rf "${EPREFIX_TMP}/*"
hash -r

# Code Listing 1.11: Updating the tree (avoid rsync protocol)
${EPREFIX}/usr/sbin/emerge-webrsync

# Code Listing 1.12: emerge an older mpc
if [ "`uname -s`" != "Darwin" ]
then
	emerge "<dev-libs/mpc-0.9"
fi

# Workaround issue where portage loses emerge history because the version Prefix has by default is too old
emerge --oneshot portage

# Code Listing 1.13: emerge system
env USE=-git emerge $ESYS_OPTS -u @system

# Code Listing 1.14: Customising the Prefix installation - example (custom)
cat << END > "${EPREFIX}/etc/make.conf"
CHOST="${CHOST}"
USE="${SAVED_USE}"
FEATURES="${FEATURES}"
CFLAGS="${SAVED_CXXFLAGS}"
CXXFLAGS="${SAVED_CXXFLAGS}"
FCFLAGS="${SAVED_FCFLAGS}"
FFLAGS="${SAVED_FFLAGS}"
LDFLAGS="${SAVED_LDFLAGS}"
MAKEOPTS="${MAKEOPTS}"
END

# Code Listing 1.15: activating the most recent compiler
if [ "`uname -s`" != "Darwin" ]
then
	gcc-config 2
fi

# Code Listing 1.16: doing the final system installation
emerge $ESYS_OPTS -e @system $@

# Code Listing 1.17: Creating a start-script
cd ${EPREFIX}/usr/portage/scripts
./bootstrap-prefix.sh ${EPREFIX} startscript
