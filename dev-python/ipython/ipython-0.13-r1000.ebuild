# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_DEPEND="<<[{*-cpython}readline?,{*-cpython}sqlite?]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 *-jython"

inherit distutils elisp-common eutils virtualx

DESCRIPTION="IPython: Productive Interactive Computing"
HOMEPAGE="http://ipython.org/ http://pypi.python.org/pypi/ipython"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 ~s390 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc emacs examples matplotlib mongodb notebook qt4 readline +smp sqlite test wxwidgets"

RDEPEND="$(python_abi_depend dev-python/decorator)
	$(python_abi_depend -e "*-pypy-*" dev-python/numpy)
	$(python_abi_depend -i "2.*" dev-python/pexpect)
	$(python_abi_depend dev-python/pyparsing)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/simplegeneric)
	$(python_abi_depend virtual/python-argparse)
	emacs? (
		app-emacs/python-mode
		virtual/emacs
	)
	matplotlib? ( $(python_abi_depend -i "2.*-cpython" dev-python/matplotlib) )
	mongodb? ( $(python_abi_depend -i "2.*" dev-python/pymongo) )
	notebook? (
		dev-libs/mathjax
		$(python_abi_depend -e "*-pypy-*" ">=dev-python/pyzmq-2.1.4")
		$(python_abi_depend -i "2.*" ">=www-servers/tornado-2.1")
	)
	qt4? (
		$(python_abi_depend dev-python/pygments)
		|| (
			$(python_abi_depend -e "*-pypy-*" dev-python/PyQt4)
			dev-python/pyside
		)
		$(python_abi_depend -e "*-pypy-*" ">=dev-python/pyzmq-2.1.4")
	)
	smp? ( $(python_abi_depend -e "*-pypy-*" ">=dev-python/pyzmq-2.1.4") )
	wxwidgets? ( $(python_abi_depend -i "2.*-cpython" dev-python/wxpython) )"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend dev-python/nose) )"

PYTHON_MODULES="IPython"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-0.12-global_path.patch"
	epatch "${FILESDIR}/${P}-python3-scripts_versioning.patch"

	# Disable failing tests.
	sed \
		-e "s/test_pylab_import_all_disabled/_&/" \
		-e "s/test_pylab_import_all_enabled/_&/" \
		-i IPython/lib/tests/test_irunner_pylab_magic.py

	# Fix installation directory for documentation.
	sed \
		-e "/docdirbase  = pjoin/s/ipython/${PF}/" \
		-e "/pjoin(docdirbase,'manual')/s/manual/html/" \
		-i setupbase.py || die "sed failed"

	if ! use doc; then
		sed \
			-e "/(pjoin(docdirbase, 'extensions'), igridhelpfiles),/d" \
			-e "s/ + manual_files//" \
			-i setupbase.py || die "sed failed"
	fi

	if ! use examples; then
		sed -e "s/ + example_files//" -i setupbase.py || die "sed failed"
	fi
}

src_compile() {
	distutils_src_compile

	if use emacs; then
		elisp-compile docs/emacs/ipython.el || die "elisp-compile failed"
	fi
}

src_test() {
	# https://github.com/ipython/ipython/issues/2083
	unset PYTHONWARNINGS

	if use mongodb; then
		mkdir -p "${T}/mongo.db"
		mongod --dbpath "${T}/mongo.db" --fork --logpath "${T}/mongo.log"
	fi

	testing() {
		"$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --root="${T}/tests-${PYTHON_ABI}" > /dev/null || die "Installation for tests failed with $(python_get_implementation_and_version)"
		# Initialize ~/.ipython directory.
		PATH="${T}/tests-${PYTHON_ABI}${EPREFIX}/usr/bin:${PATH}" PYTHONPATH="${T}/tests-${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)" ipython <<< "" > /dev/null || return 1
		# Run tests (-v for more verbosity).
		python_execute PATH="${T}/tests-${PYTHON_ABI}${EPREFIX}/usr/bin:${PATH}" PYTHONPATH="${T}/tests-${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)" iptest -v || return 1
	}
	VIRTUALX_COMMAND="python_execute_function" virtualmake testing

	if use mongodb; then
		killall -u "$(id -nu)" mongod
	fi
}

src_install() {
	distutils_src_install

	if use emacs; then
		pushd docs/emacs > /dev/null
		elisp-install ${PN} ${PN}.el*
		elisp-site-file-install "${FILESDIR}/62ipython-gentoo.el"
		popd > /dev/null
	fi

	if use notebook; then
		# Handling of MathJax library based on IPython.external.mathjax.install_mathjax().
		create_mathjax_symlink() {
			dosym "${EPREFIX}/usr/share/mathjax" "$(python_get_sitedir)/IPython/frontend/html/notebook/static/mathjax"
		}
		python_execute_function -q create_mathjax_symlink
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
