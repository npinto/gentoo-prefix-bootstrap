ifndef TOOLS_MK
TOOLS_MK=tools.mk

include init.mk

tools: eix util-linux local-overlay layman portage-tools console-tools cmake \
	ruby vim tmux tig

# ----------------------------------------------------------------------------
eix:
	${EMERGE} -uDN eix
	eix-update
ifeq ($(shell test -f ${EPREFIX}/etc/eix-sync.conf && grep "^-e" ${EPREFIX}/etc/eix-sync.conf), )
	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
endif
	${EIXSYNC}

util-linux:
	# util-linux workaround
	echo "=sys-apps/util-linux-2.18-r1 **" >> ${EPREFIX}/etc/portage/package.keywords/util-linux
	${EMERGE} -uDN util-linux

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage
	cp -va files/local_overlay/* ${EPREFIX}/usr/local/portage/
	# XXX: One could use a ifeq here
	echo "PORTDIR_OVERLAY=\"${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	${EIXSYNC}

layman: eix
	${EMERGE} -uDN layman
	layman -S
	-layman -a sekyfsr
	# XXX: One could use a ifeq here
	echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf
	${EIXSYNC}

portage-tools: local-overlay autounmask
	${EMERGE} -uDN app-portage/portage-utils
	${EMERGE} -uDN app-portage/gentoolkit
	${EMERGE} -uDN app-portage/gentoolkit-dev

autounmask:
	echo "=dev-perl/PortageXS-0.02.09 **" >> ${EPREFIX}/etc/portage/package.keywords/PortageXS-0.02.09
	echo ">dev-perl/PortageXS-0.02.09" >> ${EPREFIX}/etc/portage/package.mask/PortageXS-0.02.09+
	# XXX: ebuild needs to be patched (and pushed upstream) to prepend $EPREFIX
	${EMERGE} -uDN autounmask

console-tools:
	${EMERGE} -uDN keychain
	${EMERGE} -uDN htop
	${EMERGE} -uDN ncdu
	${EMERGE} -uDN zsh app-shells/zsh-completion
	# * If you want to enable Portage completions and Gentoo prompt,
	# * ${EMERGE} app-shells/zsh-completion and add
	# *      autoload -U compinit promptinit
	# *      compinit
	# *      promptinit; prompt gentoo
	# * to your ~/.zshrc
	# *
	# * Also, if you want to enable cache for the completions, add
	# *      zstyle ':completion::complete:*' use-cache 1
	# * to your ~/.zshrc

cmake:
	${EMERGE} -uDN libarchive
	${EMERGE} -uDN cmake

vim:
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	${EMERGE} -uDN vim vim-core
	eselect bashcomp enable --global vim &> /dev/null | exit 0

ruby:
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	${EMERGE} -uDN ruby

tmux:
	${EMERGE} -uDN tmux

tig:
	${EMERGE} -uDN tig

endif
