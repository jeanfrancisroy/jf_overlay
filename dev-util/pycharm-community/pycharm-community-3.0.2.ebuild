EAPI="4"
inherit eutils
DESCRIPTION="PyCharm"
HOMEPAGE="www.jetbrains.com/pycharm/"
SRC_URI="http://download.jetbrains.com/python/${P}.tar.gz"
KEYWORDS="~x86 ~amd64"
DEPEND=">=virtual/jre-1.6"
RDEPEND="${DEPEND}"
RESTRICT="strip mirror"
SLOT="0"
S=${WORKDIR}

MY_PN="pycharm"

src_install() {
	dodir /opt/${MY_PN}

	insinto /opt/${MY_PN}
	cd ${P}
	doins -r *
	fperms a+x /opt/${MY_PN}/bin/pycharm.sh || die "fperms failed"
	fperms a+x /opt/${MY_PN}/bin/fsnotifier || die "fperms failed"
	fperms a+x /opt/${MY_PN}/bin/fsnotifier64 || die "fperms failed"
	fperms a+x /opt/${MY_PN}/bin/inspect.sh || die "fperms failed"
	dosym /opt/${MY_PN}/bin/pycharm.sh /usr/bin/${MY_PN}

	doicon "bin/${MY_PN}.png"
	make_desktop_entry ${MY_PN} "${MY_PN}" "${MY_PN}"
}
pkg_postinst() {
	elog "Run /usr/bin/${MY_PN}"
}

