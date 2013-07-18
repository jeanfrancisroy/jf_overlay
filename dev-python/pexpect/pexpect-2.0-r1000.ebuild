# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Python module for spawning child applications and responding to expected patterns"
HOMEPAGE="http://pexpect.sourceforge.net/ http://pypi.python.org/pypi/pexpect"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/Release%20${PV}/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RESTRICT="mirror"

DEPEND=""
RDEPEND=""

PATCHES=(
	"${FILESDIR}"/${P}-fix-misc-bugs.patch
	"${FILESDIR}"/${P}-env.patch
	)

PYTHON_MODULES="ANSI.py fdpexpect.py FSM.py pexpect.py pxssh.py screen.py"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
