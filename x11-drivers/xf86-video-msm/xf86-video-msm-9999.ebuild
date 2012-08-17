# Copyright 2008-2011 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
XORG_DRI="always"
inherit linux-info xorg-2

EGIT_REPO_URI="git://codeaurora.org/quic/xwin/xf86-video-msm.git"
#EGIT_REPO_URI="git://gitorious.org/xf86-video-msm/xf86-video-msm.git"

DESCRIPTION="Xorg video driver for MSM ARM chipsets."
HOMEPAGE="https://www.codeaurora.org/contribute/projects/xwinp/"
SRC_URI=""

KEYWORDS="~*"
IUSE=""

DEPEND="x11-proto/renderproto
	x11-proto/fontsproto
	x11-proto/xproto
	>=x11-base/xorg-server-1.4"

src_prepare() {
	cd ${S}
	#epatch ${FILESDIR}/memory-allocation.patch
	#epatch ${FILESDIR}/unused-variables.patch
	epatch ${FILESDIR}/makefile-am.patch
	epatch ${FILESDIR}/no-neon-aligncopy.patch
	epatch ${FILESDIR}/makefile.patch
}
