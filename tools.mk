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
	emerge -v util-linux

mongodb:
	echo ${EPREFIX}
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy dev-db/mongodb
	echo "dev-db/mongodb v8" >> ${EPREFIX}/etc/portage/package.use/mongodb
	echo "dev-lang/v8 **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	echo "dev-db/mongodb **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	# mongodb workarounds
	-rm -vf ${EPREFIX}/etc/portage/env/dev-db/mongodb
	mkdir -p ${EPREFIX}/etc/portage/env/dev-db
	echo "export LDFLAGS=\"-L/usr/lib -L${EPREFIX}/usr/lib\"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXXFLAGS=\"-I/usr/include -I${EPREFIX}/usr/include \"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXX=g++" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	emerge -v mongodb
	# Useful aliases from:
	# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x
	# alias mongo-start="mongod --fork --dbpath \${EPREFIX}/var/lib/mongodb --logpath \${EPREFIX}/var/log/mongodb.log"
	# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
	# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

rest:
	easy_install -U pip
	pip install -vUI ipython
	pip install -vUI pycuda
	pip install -vUI joblib
	pip install -vUI scikits.learn

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

portage-tools:
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
	mkdir -p ${EPREFIX}/etc/portage/env/dev-utils
	echo "export LDFLAGS=-l:\$$(ls ${EPREFIX}/usr/lib/libz.so* | head -n 1)" >> ${EPREFIX}/etc/portage/env/dev-utils/cmake
	emerge -uDN cmake

vim:
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	# tinfo/ncurses workaround
	mkdir -p ${EPREFIX}/etc/portage/env/app-editors
	echo "export LDFLAGS=-lncurses" >> ${EPREFIX}/etc/portage/env/app-editors/vim
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
	emerge -uDN tig

endif
