# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools eutils bash-completion-r1

DESCRIPTION="Gentoo's multi-purpose configuration and management tool"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Eselect"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2+ || ( GPL-2+ CC-BY-SA-2.5 )"
SLOT="0"
KEYWORDS="~*"
IUSE="doc emacs vim-syntax"

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

PDEPEND="emacs? ( app-emacs/eselect-mode )
	vim-syntax? ( app-vim/eselect-syntax )"

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
}
