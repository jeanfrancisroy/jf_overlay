# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1"

inherit bash-completion-r1 distutils

DESCRIPTION="The PyPA recommended tool for installing Python packages."
HOMEPAGE="https://pip.pypa.io/ https://github.com/pypa/pip https://pypi.python.org/pypi/pip"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/certifi)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)"
RDEPEND="${DEPEND}"
PDEPEND="$(python_abi_depend dev-python/lockfile)"

DOCS="AUTHORS.txt CHANGES.txt docs/*.rst"

src_prepare() {
	distutils_src_prepare

	# Disable versioning of pip script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed \
		-e "/\"pip%s=pip:main\" % sys.version\[:1\]/d" \
		-e "/\"pip%s=pip:main\" % sys.version\[:3\]/d" \
		-i setup.py || die "sed failed"

	# Enable --disable-pip-version-check option by default.
	sed -e "407s/default=False/default=True/" -i pip/cmdoptions.py

	# Use system versions.
	rm -r pip/_vendor/certifi
	rm -r pip/_vendor/_markerlib
	rm -r pip/_vendor/pkg_resources
	rm pip/_vendor/six.py
}

src_install() {
	distutils_src_install

	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/pip"

	mkdir "${T}/pip_home"

	HOME="${T}/pip_home" PYTHONPATH="build-$(PYTHON -f --ABI)/lib" "$(PYTHON -f)" pip/__init__.py completion --bash > pip.bash_completion || die "Generation of bash completion file failed"
	newbashcomp pip.bash_completion pip

	HOME="${T}/pip_home" PYTHONPATH="build-$(PYTHON -f --ABI)/lib" "$(PYTHON -f)" pip/__init__.py completion --zsh > pip.zsh_completion || die "Generation of zsh completion file failed"
	insinto /usr/share/zsh/site-functions
	newins pip.zsh_completion _pip

}
