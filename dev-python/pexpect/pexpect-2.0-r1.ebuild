# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils eutils

DESCRIPTION="Python module for spawning child applications and responding to expected patterns"
HOMEPAGE="http://pexpect.sourceforge.net/"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/Release%20${PV}/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

RESTRICT="mirror"

DEPEND=""
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix-misc-bugs.patch
	# backport from pexepect-2.3 needed for sage-5.0+
	epatch "${FILESDIR}"/${P}-env.patch
}
