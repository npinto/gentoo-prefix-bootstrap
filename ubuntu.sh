#!/bin/bash

set -e
set -x

trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo "exit $?: $previous_command"' EXIT


wget -O bootstrap-prefix.sh http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt

eerror() { echo "!!! $*" 1>&2; }
if [[ "${HOST}" != "" ]] || [[ "${CFLAGS}" != "" ]] || [[ "${HOME}" != "" ]]
then
    eerror "prior to running this script, run exec -c /bin/bash --norc --noprofile"
    exit 1
fi
export HOME=`cd ~; pwd`
export EPREFIX="$HOME/gentoo"
export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:/usr/bin:/bin:$PATH"
chmod +x bootstrap-prefix.sh
./bootstrap-prefix.sh $EPREFIX tree
#./bootstrap-prefix.sh $EPREFIX/tmp gcc  # no g++ on Ubuntu by default but needs linux-headers !!!!
./bootstrap-prefix.sh $EPREFIX/tmp make
./bootstrap-prefix.sh $EPREFIX/tmp wget
./bootstrap-prefix.sh $EPREFIX/tmp sed
./bootstrap-prefix.sh $EPREFIX/tmp python
./bootstrap-prefix.sh $EPREFIX/tmp coreutils6
./bootstrap-prefix.sh $EPREFIX/tmp findutils
#./bootstrap-prefix.sh $EPREFIX/tmp findutils3
#./bootstrap-prefix.sh $EPREFIX/tmp tar
./bootstrap-prefix.sh $EPREFIX/tmp tar15
./bootstrap-prefix.sh $EPREFIX/tmp patch
./bootstrap-prefix.sh $EPREFIX/tmp grep
./bootstrap-prefix.sh $EPREFIX/tmp gawk
./bootstrap-prefix.sh $EPREFIX/tmp m4  # require to get bison to build
./bootstrap-prefix.sh $EPREFIX/tmp bison  # no yacc on Ubuntu by default
./bootstrap-prefix.sh $EPREFIX/tmp bash
hash -r
./bootstrap-prefix.sh $EPREFIX portage
export LDFLAGS="-L${EPREFIX}/usr/lib -R${EPREFIX}/usr/lib -L${EPREFIX}/lib -R${EPREFIX}/lib"
export CPPFLAGS="-I${EPREFIX}/usr/include"
hash -r
export USE="-berkdb -fortran -gdbm -nls -pcre -ssl -pam"
emerge --oneshot sed
emerge --oneshot --nodeps wget
emerge --oneshot bash
emerge --oneshot --nodeps baselayout-prefix
emerge --oneshot --nodeps lzma-utils
emerge --oneshot --nodeps m4
emerge --oneshot --nodeps flex
emerge --oneshot --nodeps bison
emerge --oneshot --nodeps binutils-config
emerge --oneshot --nodeps binutils
emerge --oneshot --nodeps gcc-config
#emerge --oneshot gcc
emerge --oneshot --nodeps "=gcc-4.2*"
unset LDFLAGS CPPFLAGS CHOST CC CXX HOSTCC
export CFLAGS=""  # coreutils throws some sort of error if CFLAGS not set
emerge --oneshot coreutils
emerge --oneshot findutils
#emerge --oneshot tar
emerge --oneshot grep
emerge --oneshot patch
emerge --oneshot gawk
emerge --oneshot make
emerge --oneshot --nodeps file
emerge --oneshot --nodeps eselect
rm $EPREFIX/usr/share/man/man1/{env-update,quickpkg,dispatch-conf,repoman,emerge,emaint,ebuild,etc-update}.1
env FEATURES="-collision-protect" emerge --oneshot portage
#rm -Rf $EPREFIX/tmp/*
mv $EPREFIX/tmp $EPREFIX/tmp.old
hash -r
emerge --sync
emerge -u system
