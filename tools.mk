ifndef TOOLS_MK
TOOLS_MK=tools.mk

include init.mk

tools: eix util-linux local-overlay layman portage-tools console-tools cmake \
	ruby vim tmux tig

# ----------------------------------------------------------------------------
eix:
	emerge -uDN eix
	eix-update
ifeq ($(shell test -f ${EPREFIX}/etc/eix-sync.conf && grep "^-e" ${EPREFIX}/etc/eix-sync.conf), )
	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
endif
	eix-sync

util-linux:
	# util-linux workaround
	echo "=sys-apps/util-linux-2.18-r1 **" >> ${EPREFIX}/etc/portage/package.keywords/util-linux
	#emerge --oneshot --nodeps util-linux
	emerge -uDN util-linux

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage/profiles
	# XXX: One could use a ifeq here
	#echo "PORTDIR_OVERLAY=\"\$${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "PORTDIR_OVERLAY=\"${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "local-overlay" > ${EPREFIX}/usr/local/portage/profiles/repo_name
	eix-sync

layman: eix
	emerge -uDN layman
	layman -S
	-layman -a sekyfsr
	# XXX: One could use a ifeq here
	echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf
	eix-sync

portage-tools: local-overlay
	emerge -uDN app-portage/portage-utils
	emerge -uDN app-portage/gentoolkit
	emerge -uDN app-portage/gentoolkit-dev
	emerge -uDN autounmask

console-tools:
	emerge -uDN keychain
	emerge -uDN htop
	emerge -uDN ncdu
	emerge -uDN zsh
	# * If you want to enable Portage completions and Gentoo prompt,
	# * emerge app-shells/zsh-completion and add
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
	emerge -uDN libarchive
	# cmake workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/dev-util
	#-rm -vf ${EPREFIX}/etc/portage/env/dev-util/cmake
	#echo "export LDFLAGS=-l:\$$(ls \$${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-util/cmake
	#emerge -uDN cmake
	emerge -uDN cmake

vim:
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	# tinfo/ncurses workaround
	#mkdir -p ${EPREFIX}/etc/portage/env/app-editors
	#echo "export LDFLAGS=-lncurses" >> ${EPREFIX}/etc/portage/env/app-editors/vim
	emerge -uDN vim vim-core
	eselect bashcomp enable --global vim &> /dev/null | exit 0

ruby:
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	emerge -uDN ruby

tmux:
	# tinfo/ncurses workaround
	mkdir -p ${EPREFIX}/etc/portage/env/app-misc
	echo "export LDFLAGS=\"-l:${EPREFIX}/usr/lib/libevent.so \$$LDFLAGS\"" >> ${EPREFIX}/etc/portage/env/app-misc/tmux
	emerge -uDN tmux

tig:
	mkdir -p ${EPREFIX}/etc/portage/env/dev-vcs
	-rm -vf ${EPREFIX}/etc/portage/env/dev-vcs/tig
	echo "export LDFLAGS=-l:\$$(ls \$${EPREFIX}/usr/lib/libncursesw.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-vcs/tig
	emerge -v tig

endif
