EAPI="4"
inherit eutils
DESCRIPTION="PyCharm"
HOMEPAGE="www.jetbrains.com/pycharm/"
SRC_URI="http://download.jetbrains.com/python/pycharm-professional-${PV}.tar.gz"
KEYWORDS="~x86 ~amd64"
DEPEND=">=virtual/jre-1.6"
RDEPEND="${DEPEND}"
RESTRICT="strip mirror"
SLOT="0"
S=${WORKDIR}
src_install() {
	dodir /opt/${PN}

	insinto /opt/${PN}
	cd pycharm-${PVERSION}
	doins -r *
	fperms a+x /opt/${PN}/${P}/bin/pycharm.sh || die "fperms failed"
	fperms a+x /opt/${PN}/${P}/bin/fsnotifier || die "fperms failed"
	fperms a+x /opt/${PN}/${P}/bin/fsnotifier64 || die "fperms failed"
	fperms a+x /opt/${PN}/${P}/bin/inspect.sh || die "fperms failed"
	dosym /opt/${PN}/${P}/bin/pycharm.sh /usr/bin/${PN}

	doicon "bin/${PN}.png"
	make_desktop_entry ${PN} "${PN}" "${PN}"
}
pkg_postinst() {
	elog "Run /usr/bin/${PN}"
}

