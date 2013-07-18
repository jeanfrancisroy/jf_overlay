# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 *-jython"

inherit distutils

DESCRIPTION="Python package for creating and manipulating graphs and networks"
HOMEPAGE="http://networkx.lanl.gov/ https://pypi.python.org/pypi/networkx"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples graphviz matplotlib numpy pyparsing scipy yaml"
REQUIRED_USE="examples? ( graphviz matplotlib numpy pyparsing scipy )"

RDEPEND="$(python_abi_depend dev-python/decorator)
	graphviz? ( $(python_abi_depend -e "3.*" dev-python/pygraphviz) )
	matplotlib? ( $(python_abi_depend -e "*-pypy-*" dev-python/matplotlib) )
	numpy? ( $(python_abi_depend -e "*-pypy-*" dev-python/numpy) )
	pyparsing? ( $(python_abi_depend dev-python/pyparsing) )
	scipy? ( $(python_abi_depend -e "*-pypy-*" sci-libs/scipy) )
	yaml? ( $(python_abi_depend dev-python/pyyaml) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? (
		dev-python/matplotlib[python_abis_2.7]
		dev-python/sphinx[python_abis_2.7]
	)"

src_prepare() {
	distutils_src_prepare

	# Do not use internal copy of dev-python/decorator.
	rm -f networkx/external/decorator/{_decorator.py,_decorator3.py}
	echo "from decorator import *" > networkx/external/decorator/__init__.py

	# Disable installation of INSTALL.txt and LICENSE.txt.
	sed -e 's/data = \[(docdirbase, glob("\*.txt"))\]/data = [(docdirbase, [x for x in glob("*.txt") if x not in ("INSTALL.txt", "LICENSE.txt")])]/' -i setup.py

	python_convert_shebangs 2.7 doc/{make_examples_rst.py,make_gallery.py}
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH=".." emake html SPHINXBUILD="sphinx-build-2.7"
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/build/html/*
	fi

	if ! use examples; then
		rm -fr "${ED}usr/share/doc/${PF}/examples"
	fi
}
