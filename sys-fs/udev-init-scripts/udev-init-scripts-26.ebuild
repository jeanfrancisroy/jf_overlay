# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev-init-scripts/udev-init-scripts-26.ebuild,v 1.12 2013/06/30 18:05:51 ago Exp $

EAPI=5

inherit eutils

if [ "${PV}" = "9999" ]; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/udev-gentoo-scripts.git"
	inherit git-2
fi

DESCRIPTION="udev startup scripts for openrc"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

if [ "${PV}" != "9999" ]; then
	SRC_URI="http://dev.gentoo.org/~williamh/dist/${P}.tar.bz2"
	KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86"
fi

RESTRICT="test"

DEPEND="virtual/pkgconfig"
RDEPEND=">=virtual/udev-180
	sys-apps/openrc
	!<sys-fs/udev-186"

src_prepare()
{
	epatch_user
}

