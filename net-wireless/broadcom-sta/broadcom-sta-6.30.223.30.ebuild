# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/broadcom-sta/broadcom-sta-6.30.223.30.ebuild,v 1.1 2013/05/01 07:22:47 pinkbyte Exp $

EAPI="5"
inherit eutils linux-mod unpacker

DESCRIPTION="Broadcom's IEEE 802.11a/b/g/n hybrid Linux device driver."
HOMEPAGE="https://launchpad.net/ubuntu/+source/bcmwl http://www.broadcom.com/support/802.11/linux_sta.php"
BASE_URI="https://launchpad.net/~albertomilone/+archive/broadcom/+files"
BASE_NAME="bcmwl-kernel-source_${PV}%2Bbdcom-0ubuntu1%7Eppa1_"
SRC_URI="amd64? ( ${BASE_URI}/${BASE_NAME}amd64.deb )
		x86? ( ${BASE_URI}/${BASE_NAME}i386.deb )"

LICENSE="Broadcom"
KEYWORDS="-* ~amd64 ~x86"

RESTRICT="mirror"

DEPEND="virtual/linux-sources"
RDEPEND=""

#S="${WORKDIR}"
S="${WORKDIR}/usr/src/bcmwl-${PV}+bdcom"

MODULE_NAMES="wl(net/wireless)"
MODULESD_WL_ALIASES=("wlan0 wl")

pkg_setup() {
	# bug #300570
	# NOTE<lxnay>: module builds correctly anyway with b43 and SSB enabled
	# make checks non-fatal. The correct fix is blackisting ssb and, perhaps
	# b43 via udev rules. Moreover, previous fix broke binpkgs support.
	CONFIG_CHECK="~!B43 ~!SSB"
	if kernel_is ge 2 6 32; then
		CONFIG_CHECK="${CONFIG_CHECK} CFG80211 LIB80211 ~!MAC80211"
	elif kernel_is ge 2 6 31; then
		CONFIG_CHECK="${CONFIG_CHECK} LIB80211 WIRELESS_EXT ~!MAC80211"
	elif kernel_is ge 2 6 29; then
		CONFIG_CHECK="${CONFIG_CHECK} LIB80211 WIRELESS_EXT ~!MAC80211 COMPAT_NET_DEV_OPS"
	elif kernel_is ge 3 8 0; then
		ewarn "Due to licensing issues this driver is unusable with kernel 3.8."
		ewarn "Meaning: This build will likely not succeed."
	else
		CONFIG_CHECK="${CONFIG_CHECK} IEEE80211 IEEE80211_CRYPT_TKIP"
	fi
	linux-mod_pkg_setup

	BUILD_PARAMS="-C ${KV_DIR} M=${S}"
	BUILD_TARGETS="wl.ko"
}

src_unpack() {
	local arch_suffix
	if use amd64; then
		arch_suffix="amd64"
	else
		arch_suffix="i386"
	fi
	unpack_deb "${BASE_NAME}${arch_suffix}.deb"
}

src_prepare() {
	einfo
	einfo "These patches come from some mighty proficient Debian programmer"
	einfo "whose work I shamelessly exploit for Gentoo's benefit."
	einfo "This ebuild was tested with 3.7.10-gentoo-r1."
	einfo "If one of them patches fails against other versions, please"
	einfo "file a bug about it at https://bugs.gentoo.org"
	einfo
#	Filter the outdated patches here
#	This needs more testing against multiple versions.
#	So far the filtered patches seem to be cruft from older versions.
	EPATCH_FORCE="yes" EPATCH_EXCLUDE="0002* 0004* 0005*" EPATCH_SOURCE="${S}/patches" EPATCH_SUFFIX=patch epatch
#	keep `emake install` working
	epatch "${FILESDIR}/${P}-makefile.patch"
	epatch "${FILESDIR}/${P}-linux39.patch"

	mv "${S}/lib/wlc_hybrid.o_shipped_"* "${S}/lib/wlc_hybrid.o_shipped" \
		|| die "Where is the blob?"

	epatch_user
}
