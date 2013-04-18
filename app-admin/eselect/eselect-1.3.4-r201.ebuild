# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.3.4.ebuild,v 1.1 2013/01/06 19:10:44 ulm Exp $

EAPI=4

inherit bash-completion-r1 eutils autotools

DESCRIPTION="Gentoo's multi-purpose configuration and management tool"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"
IUSE="doc"

RDEPEND="sys-apps/sed
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-misc/realpath
	)"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	doc? ( dev-python/docutils )"
RDEPEND="!app-admin/eselect-news
	${RDEPEND}
	sys-apps/file
	sys-libs/ncurses"

# Commented out: only few users of eselect will edit its source
#PDEPEND="emacs? ( app-emacs/gentoo-syntax )
#	vim-syntax? ( app-vim/eselect-syntax )"

src_prepare() {
	epatch "${FILESDIR}"/${PVR}/${PN}-alternatives.patch
	AT_M4DIR="." eautoreconf
}

src_compile() {
	emake
	use doc && emake html
}

src_install() {
	emake DESTDIR="${D}" install
	newbashcomp misc/${PN}.bashcomp ${PN}
	dodoc AUTHORS ChangeLog NEWS README TODO doc/*.txt
	use doc && dohtml *.html doc/*

	# needed by news module
	keepdir /var/lib/gentoo/news
	if ! use prefix; then
		fowners root:portage /var/lib/gentoo/news
		fperms g+w /var/lib/gentoo/news
	fi

	# band aid for prefix
	if use prefix; then
		cd "${ED}"/usr/share/eselect/libs
		sed -i "s:ALTERNATIVESDIR_ROOTLESS=\"${EPREFIX}:ALTERNATIVESDIR_ROOTLESS=\":" alternatives.bash || die
	fi

	# tweaks for funtoo-1.0 profile
	insinto /usr/share/eselect/modules
	doins $FILESDIR/$PVR/profile.eselect || die
	doins $FILESDIR/$PVR/kernel.eselect || die
}

pkg_postinst() {
	# fowners in src_install doesn't work for the portage group:
	# merging changes the group back to root
	if ! use prefix; then
		chgrp portage "${EROOT}/var/lib/gentoo/news" \
			&& chmod g+w "${EROOT}/var/lib/gentoo/news"
	fi
	ewarn "This version of eselect supports using /etc/portage/make.profile along with the new Funtoo 1.0 profiles."
	ewarn "Please visit http://www.funtoo.org/wiki/Funtoo_1.0_Profile for instructions on how to switch"
}
