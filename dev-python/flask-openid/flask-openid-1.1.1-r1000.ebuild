# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.*"

inherit distutils

MY_PN="Flask-OpenID"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="OpenID support for Flask"
HOMEPAGE="http://pypi.python.org/pypi/Flask-OpenID"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc examples"

RDEPEND="$(python_abi_depend ">=dev-python/flask-0.3")
	$(python_abi_depend ">=dev-python/python-openid-2.0")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="flask_openid.py"

src_prepare() {
	distutils_src_prepare

	# Fix Sphinx theme.
	sed \
		-e "s/html_theme = 'flask_small'/html_theme = 'default'/" \
		-e "/^html_theme_options = {$/,/^}$/d" \
		-i docs/conf.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH=".." emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r example/*
	fi
}
