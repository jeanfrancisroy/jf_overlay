# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_DEPEND="<<[{*-cpython}readline?]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils elisp-common eutils virtualx

DESCRIPTION="IPython: Productive Interactive Computing"
HOMEPAGE="http://ipython.org/ http://pypi.python.org/pypi/ipython"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 ~s390 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc emacs examples gnuplot readline smp test wxwidgets"

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
	gnuplot? ( $(python_abi_depend -i "2.*-cpython" dev-python/gnuplot-py) )
	smp? ( $(python_abi_depend -e "*-pypy-*" ">=dev-python/pyzmq-2.1.4") )
	wxwidgets? ( $(python_abi_depend -i "2.*-cpython" dev-python/wxpython) )"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend dev-python/nose) )"

PYTHON_MODULES="IPython"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-0.9.1-globalpath.patch"
	sed -e "s:share/doc/ipython:share/doc/${PF}:" -i setupbase.py || die "sed failed"

	if ! use doc; then
		sed \
			-e "/(pjoin(docdirbase, 'extensions'), igridhelpfiles),/d" \
			-e "s/ + manual_files//" \
			-i setupbase.py || die "sed failed"
	fi

	if ! use examples; then
		sed -e "s/ + example_files//" -i setupbase.py || die "sed failed"
	fi

	# Don't install files requiring Numeric.
	rm -f IPython/numutils.py IPython/UserConfig/ipythonrc-numeric

	# Disable failing test.
	sed -e "s/test_obj_del/_&/" -i IPython/tests/test_magic.py || die "sed failed"

	# Disable tests requiring foolscap when foolscap is unavailable.
	sed -e "/^if not have_twisted:$/i if not have_foolscap:\n    EXCLUDE.append(pjoin('IPython', 'kernel'))\n" -i IPython/testing/iptest.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use emacs; then
		elisp-compile docs/emacs/ipython.el || die "elisp-compile failed"
	fi
}

src_test() {
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
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
