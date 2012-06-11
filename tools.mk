ifndef TOOLS_MK
TOOLS_MK=tools.mk

# TODO: move some of these recipes to mygentoo

include init.mk

tools: eix util-linux local-overlay layman portage-tools
#tools: eix util-linux local-overlay layman portage-tools console-tools cmake \
#	ruby vim tmux tig fabric

# ----------------------------------------------------------------------------
eix:
	${EMERGE} -uN eix
	eix-update
#ifeq ($(shell test -f ${EPREFIX}/etc/eix-sync.conf && grep "^-e" ${EPREFIX}/etc/eix-sync.conf), )
#	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
#endif
	${EIXSYNC}

util-linux:
	# util-linux workaround
	#echo "=sys-apps/util-linux-2.18-r1 **" >> ${EPREFIX}/etc/portage/package.keywords/util-linux
	#${EMERGE} -uN util-linux
	${EMERGE} -uN util-linux

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage
	cp -va files/local_overlay/* ${EPREFIX}/usr/local/portage/
	# XXX: should use a ifeq here
	echo "PORTDIR_OVERLAY=\"${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	${EIXSYNC}

layman: eix
	${EMERGE} -uN layman
	layman -S
	-layman -a sekyfsr
	# XXX: should use a ifeq here
	echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf
	${EIXSYNC}

portage-tools: local-overlay
	${EMERGE} -uN app-portage/portage-utils
	${EMERGE} -uN app-portage/gentoolkit
	${EMERGE} -uN app-portage/gentoolkit-dev

#console-tools:
#	${EMERGE} -uN keychain
#	${EMERGE} -uN htop
#	${EMERGE} -uN ncdu
#	${EMERGE} -uN zsh app-shells/zsh-completion
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

#cmake:
#	${EMERGE} -uN libarchive
	#cp -vf files/etc/portage/package.use/cmake \
		#${EPREFIX}/etc/portage/package.use/cmake
#	cp -vf {files,${EPREFIX}}/etc/portage/package.use/cmake
#	${EMERGE} -uN cmake

#vim:
#	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
#	${EMERGE} -uN vim vim-core
#	eselect bashcomp enable --global vim &> /dev/null | exit 0

#ruby:
#	cp -f {files,${EPREFIX}}/etc/portage/package.use/ruby
#	cp -f {files,${EPREFIX}}/etc/portage/package.mask/ruby
#	${EMERGE} -uN -j dev-lang/ruby dev-ruby/rubygems
#	eselect ruby set ruby18

#tmux:
#	${EMERGE} -uN tmux

#tig:
#	${EMERGE} -uN tig

#fabric: pip
#	pip install -vU fabric

endif
