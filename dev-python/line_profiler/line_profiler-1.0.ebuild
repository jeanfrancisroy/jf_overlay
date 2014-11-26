# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1

DESCRIPTION="Line-by-line profiler."
HOMEPAGE="http://packages.python.org/line_profiler"
SRC_URI="http://pypi.python.org/packages/source/l/line_profiler/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

