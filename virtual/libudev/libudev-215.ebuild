# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit multilib-build

DESCRIPTION="Virtual for libudev providers"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0/1"
KEYWORDS="*"
IUSE="+static-libs systemd"

DEPEND=""
RDEPEND="
	!systemd? ( >=sys-fs/eudev-1.3:0/0[${MULTILIB_USEDEP},static-libs?] )
	systemd? ( !static-libs? ( >=sys-apps/systemd-212-r5:0/2[${MULTILIB_USEDEP}] ) )"
