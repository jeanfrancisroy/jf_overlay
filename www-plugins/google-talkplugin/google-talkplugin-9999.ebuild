# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit nsplugins multilib

DESCRIPTION="Video chat browser plug-in for Google Talk"
HOMEPAGE="http://www.google.com/chat/video"
SRC_URI="x86? ( http://dl.google.com/linux/direct/${PN}_current_i386.deb )
	amd64? ( http://dl.google.com/linux/direct/${PN}_current_amd64.deb )"

IUSE="-chromium"
SLOT="0"
LICENSE="UNKNOWN"
KEYWORDS="~amd64"
RESTRICT="strip"

S="${WORKDIR}"

RDEPEND="x86? ( virtual/opengl
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib
	media-gfx/nvidia-cg-toolkit
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/glitz
	media-libs/libpng
	x11-libs/cairo
	x11-libs/gtk+
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
	x11-libs/pixman )
	amd64? ( app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-xlibs )"
DEPEND="${RDEPEND}"

INSTALL_BASE="/opt/google/talkplugin"

src_unpack() {
	unpack ${A}
	unpack ./data.tar.gz
}

src_install() {
	arch=""
	[ "$ARCH" == "amd64" ] && arch="64"
	for i in GoogleTalkPlugin "libnpgoogletalk${arch}.so" libnpgtpo3dautoplugin.so; do
	exeinto ${INSTALL_BASE}
	doexe "${WORKDIR}"/opt/google/talkplugin/${i}
	done

	inst_plugin "${INSTALL_BASE}/libnpgoogletalk${arch}.so"
	inst_plugin "${INSTALL_BASE}/libnpgtpo3dautoplugin.so"

	mkdir -p ${D}/lib
	ln -s /opt/google/talkplugin/lib/libCg.so "${D}/lib"
	mv opt/google/talkplugin/lib "${D}/opt/google/talkplugin/"
	if use chromium ; then
		mkdir -p "${D}usr/lib${arch}/chromium-browser"
		cp -a "${D}usr/lib${arch}/nsbrowser/plugins/libnpg"* "${D}usr/lib${arch}/chromium-browser"

	fi
}
