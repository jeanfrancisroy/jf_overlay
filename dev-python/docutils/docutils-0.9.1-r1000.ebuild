# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Docutils - Python Documentation Utilities"
HOMEPAGE="http://docutils.sourceforge.net/ http://pypi.python.org/pypi/docutils"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI="http://people.apache.org/~Arfrever/gentoo/${P}.tar.xz"
else
	SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
fi
SRC_URI+=" glep? ( mirror://gentoo/glep-0.4-r1.tbz2 )"

LICENSE="BSD-2 GPL-3 public-domain"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="glep"

DEPEND="$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/roman)"
RDEPEND="${DEPEND}"

DOCS="*.txt"

GLEP_SRC="${WORKDIR}/glep-0.4-r1"

src_compile() {
	distutils_src_compile

	# Generate html docs from reStructured text sources.

	# Place html4css1.css in base directory to ensure that the generated reference to it is correct.
	cp docutils/writers/html4css1/html4css1.css .

	pushd tools > /dev/null

	python_execute PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" "$(PYTHON -f)" ../tools/buildhtml.py --input-encoding=utf-8 --stylesheet-path=../html4css1.css --traceback ../docs || die "buildhtml.py failed"

	popd > /dev/null

	# Clean up after building of documentation.
	rm html4css1.css
}

src_test() {
	testing() {
		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/alltests.py
		else
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test3/alltests.py
		fi
	}
	python_execute_function testing
}

install_txt_doc() {
	local doc="${1}"
	local dir="txt/$(dirname ${doc})"
	docinto "${dir}"
	dodoc "${doc}"
}

src_install() {
	distutils_src_install

	postinstallational_preparation() {
		# Install tools.
		mkdir -p "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/bin"
		pushd tools > /dev/null
		cp buildhtml.py quicktest.py "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/bin"
		popd > /dev/null
	}
	python_execute_function -q postinstallational_preparation
	python_merge_intermediate_installation_images "${T}/images"

	# Install documentation.
	dohtml -r docs tools

	# Install stylesheet file.
	insinto /usr/share/doc/${PF}/html
	doins docutils/writers/html4css1/html4css1.css
	local doc
	for doc in {docs,tools}/**/*.txt; do
		install_txt_doc "${doc}"
	done

	# Install Gentoo GLEP tools.
	if use glep; then
		dobin "${GLEP_SRC}/glep.py"

		installation_of_glep_tools() {
			insinto $(python_get_sitedir)/docutils/readers
			newins "${GLEP_SRC}/glepread.py" glep.py
			insinto $(python_get_sitedir)/docutils/transforms
			newins "${GLEP_SRC}/glepstrans.py" gleps.py
			insinto $(python_get_sitedir)/docutils/writers
			doins -r "${GLEP_SRC}/glep_html"
		}
		python_execute_function --action-message 'Installation of GLEP tools with $(python_get_implementation_and_version)' installation_of_glep_tools
	fi
}
