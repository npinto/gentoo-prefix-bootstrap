#!/bin/bash

source ./init.sh

# ----------------------------------------------------------------------------

# keychain
emerge -uDN keychain

# vim
echo "app-editors/vim bash-completion vim-pager python ruby" >> $EPREFIX/etc/portage/package.use/vim
emerge -juN vim{,-core}


# eix
emerge -uDN eix
eix-update
echo -e '\055e' >> $EPREFIX/etc/eix-sync.conf
eix-sync

# other portage / gentoo related
emerge -uDN app-portage/portage-utils
emerge -uDN app-portage/gentoolkit
emerge -uDN app-portage/gentoolkit-dev

# layman
emerge -uDN layman
if [ ! -d $EPREFIX/var/lib/layman/sekyfsr ]; then
    layman -S;
    layman -a sekyfsr;
    echo "source $EPREFIX/var/lib/layman/make.conf" >> $EPREFIX/etc/make.conf;
fi;
eix-sync

# local overlay
mkdir -p $EPREFIX/usr/local/portage/profiles
echo "local_overlay" > $EPREFIX/usr/local/portage/profiles/repo_name
echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} $EPREFIX/usr/local/portage/\"" >> $EPREFIX/etc/make.conf

# autounmask
emerge -uDN autounmask
