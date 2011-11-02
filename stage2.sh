wget https://raw.github.com/gist/1294750/d96a4b0f2be742dcca3adcb220a603b2260c4cc9/bootstrap-prefix-python-disable-crypt-nis.patch
patch -p0 < bootstrap-prefix-python-disable-crypt-nis.patch
mv -vf bootstrap-prefix.sh bootstrap-prefix-patched.sh
chmod 755 bootstrap-prefix-patched.sh
./bootstrap-prefix-patched.sh /home/pinto/gentoo tree
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp make
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp wget
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp sed
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp coreutils6
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp findutils5
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp tar15
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp patch
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp grep
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp gawk
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp zlib
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp python
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp m4
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp bison
./bootstrap-prefix-patched.sh /home/pinto/gentoo/tmp bash
hash -r
./bootstrap-prefix-patched.sh /home/pinto/gentoo portage
mkdir -p /home/pinto/gentoo/etc/portage/package.keywords
mkdir -p /home/pinto/gentoo/etc/portage/package.use
mkdir -p /home/pinto/gentoo/etc/portage/package.mask

emerge --quiet --oneshot sed
emerge --quiet --oneshot --nodeps bash
emerge --quiet --oneshot --nodeps xz-utils
emerge --quiet --oneshot wget
emerge --quiet --oneshot --nodeps baselayout-prefix
emerge --quiet --oneshot --nodeps m4
emerge --quiet --oneshot --nodeps flex
emerge --quiet --oneshot --nodeps bison

emerge --quiet --oneshot --nodeps binutils-config
MAKEOPTS=-j1 emerge --quiet --oneshot --nodeps binutils
emerge --quiet --oneshot --nodeps gcc-config
emerge --quiet --oneshot --nodeps "=gcc-4.2.4-r01.4"
echo ">sys-devel/gcc-4.2.4-r01.4" > /home/pinto/gentoo/etc/portage/package.mask/gcc-4.2.4-r01.4+

emerge --quiet --oneshot coreutils
emerge --quiet --oneshot perl < /dev/null
emerge --quiet --oneshot findutils
emerge --quiet --oneshot tar
emerge --quiet --oneshot grep
emerge --quiet --oneshot patch
emerge --quiet --oneshot gawk
emerge --quiet --oneshot make
emerge --quiet --oneshot --nodeps file
emerge --quiet --oneshot --nodeps eselect
emerge --quiet --oneshot pax-utils

mkdir -p /home/pinto/gentoo/etc/portage/env/dev-lang/
echo "export LDFLAGS='-L/usr/lib64'" > /home/pinto/gentoo/etc/portage/env/dev-lang/python

env FEATURES="-collision-protect" emerge --quiet --oneshot portage

mv -f /home/pinto/gentoo/tmp /home/pinto/gentoo/tmp.old
emerge --quiet --sync


