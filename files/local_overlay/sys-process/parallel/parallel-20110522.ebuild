# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/parallel/parallel-20110522.ebuild,v 1.1 2011/06/02 07:26:49 fauli Exp $

EAPI=3

DESCRIPTION="A shell tool for executing jobs in parallel locally or on remote machines"
HOMEPAGE="http://www.gnu.org/software/parallel/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux"
IUSE=""

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e '/^[ \t]*$Global::progname[ \t]*=/ s/parallel/gparallel/' \
		src/parallel || die
}

src_configure() {
	econf --program-transform-name='s/parallel/gparallel/' || die
}

src_install() {
	emake install DESTDIR="${D}" docdir="${EPREFIX}"/usr/share/doc/${PF}/html || die

	# --program-transform-* care about only bin and man.
	mv "${ED}"/usr/share/doc/${PF}/html/{,g}parallel.html || die

	rm -f "${ED}"/usr/bin/sem || die
	dosym gparallel /usr/bin/sem
	dodoc NEWS README || die
}

pkg_postinst() {
	ewarn "'parallel' command has been renamed to 'gparallel' to avoid"
	ewarn "a naming collision with sys-apps/moreutils."
	elog "To distribute jobs to remote machines you'll need these dependencies"
	elog " net-misc/openssh"
	elog " net-misc/rsync"
}
