include init.mk

# ============================================================================
# == install_system_tools
# ============================================================================

default: install_system_tools
#.PHONY: stage0 stage1 stage2 stage3 stage4

# ----------------------------------------------------------------------------
install_system_tools: eix local-overlay layman
	# -- keychain:
	emerge -uDN keychain
	# -- vim:
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	emerge -juN vim vim-core
	# --ruby: portage-utils
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	emerge -juN ruby
	# -- portage-utils: eix
	emerge -uDN app-portage/portage-utils
	emerge -uDN app-portage/gentoolkit
	emerge -uDN app-portage/gentoolkit-dev
	emerge -uDN autounmask

eix: ${EPREFIX}/usr/bin/eix
	emerge -uDN eix
	eix-update
	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
# XXX: Here is a better version of the line above... cleaner but much more verbose
#ifeq ($(shell test -f ${EPREFIX}/etc/eix-sync.conf && grep "^-e" ${EPREFIX}/etc/eix-sync.conf), )
	#echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
#endif
	eix-sync

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage/profiles
	#echo "PORTDIR_OVERLAY=\"\$${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "PORTDIR_OVERLAY=\"${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "local_overlay" > ${EPREFIX}/usr/local/portage/profiles/repo_name
	eix-sync

layman: eix
	emerge -uDN layman
	layman -S
	layman -a sekyfsr
	# XXX: One could use a ifeq here
	echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf
	eix-sync
