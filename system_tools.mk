include init.mk

# ============================================================================
# == install_system_tools
# ============================================================================

default: install_system_tools
#.PHONY: stage0 stage1 stage2 stage3 stage4

#install_system_tools: stage0.done

# ----------------------------------------------------------------------------
#stage0.done:
install_system_tools: portage-utils
	# keychain
	emerge -uDN keychain

	# ruby
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	emerge -juN ruby

	# vim
	echo "app-editors/vim bash-completion vim-pager python ruby" >> ${EPREFIX}/etc/portage/package.use/vim
	emerge -juN vim vim-core

portage-utils:
	# eix
	emerge -uDN eix
	eix-update
	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
	eix-sync
	# other portage / gentoo related
	emerge -uDN app-portage/portage-utils
	emerge -uDN app-portage/gentoolkit
	emerge -uDN app-portage/gentoolkit-dev
	# layman
	emerge -uDN layman
	if [ ! -d ${EPREFIX}/var/lib/layman/sekyfsr ]; then
		layman -S;
		layman -a sekyfsr;
		echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf;
	fi;
	eix-sync
	# local overlay
	mkdir -p ${EPREFIX}/usr/local/portage/profiles
	echo "local_overlay" > ${EPREFIX}/usr/local/portage/profiles/repo_name
	echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	# autounmask
	emerge -uDN autounmask

# ----------------------------------------------------------------------------
# -- STAGE 0
# ----------------------------------------------------------------------------
#stage0: stage0.done
	#touch $@

