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
	#${EMERGE} --oneshot --nodeps util-linux
	${EMERGE} -uDN util-linux

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage
	cp -va files/local_overlay/* ${EPREFIX}/usr/local/portage/
	# XXX: One could use a ifeq here
	#echo "PORTDIR_OVERLAY=\"\$${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
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
	${EMERGE} -uDN autounmask

console-tools:
	${EMERGE} -uDN keychain
	${EMERGE} -uDN htop
	${EMERGE} -uDN ncdu
	${EMERGE} -uDN zsh
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
	# libarchive workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/app-arch
	#-rm -vf ${EPREFIX}/etc/portage/env/app-arch/libarchive
	#echo "export LDFLAGS=-l:\$$(ls \$${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/app-arch/libarchive
	${EMERGE} -uDN libarchive
	# cmake workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/dev-util
	#-rm -vf ${EPREFIX}/etc/portage/env/dev-util/cmake
	#echo "export LDFLAGS=-l:\$$(ls \$${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-util/cmake
	#${EMERGE} -uDN cmake
	${EMERGE} -uDN cmake

vim:
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	# tinfo/ncurses workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/app-editors
	#echo "export LDFLAGS=-lncurses" >> ${EPREFIX}/etc/portage/env/app-editors/vim
	${EMERGE} -uDN vim vim-core
	eselect bashcomp enable --global vim &> /dev/null | exit 0

ruby:
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	${EMERGE} -uDN ruby

tmux:
	# tinfo/ncurses workaround
	mkdir -p ${EPREFIX}/etc/portage/env/app-misc
	echo "export LDFLAGS=\"-l:${EPREFIX}/usr/lib/libevent.so \$$LDFLAGS\"" >> ${EPREFIX}/etc/portage/env/app-misc/tmux
	${EMERGE} -uDN tmux

tig:
	mkdir -p ${EPREFIX}/etc/portage/env/dev-vcs
	-rm -vf ${EPREFIX}/etc/portage/env/dev-vcs/tig
	echo "export LDFLAGS=-l:\$$(ls \$${EPREFIX}/usr/lib/libncursesw.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-vcs/tig
	${EMERGE} -v tig

endif
