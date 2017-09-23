# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='threads(+)' # required by waf
inherit python-single-r1 waf-utils

DESCRIPTION="Tool for flashing Rockchip devices"
HOMEPAGE="https://github.com/linuxerwang/rkflashkit"
SRC_URI="https://github.com/linuxerwang/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-python/pygtk[${PYTHON_USEDEP}]
	virtual/libusb:1
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

NO_WAF_LIBDIR=1

src_prepare() {
	sed -i -e "s#debian/usr/share#usr/share#" -e "s/0.1.0/${PV}/" wscript || die
	sed -i -e "s#src#/usr/share/rkflashkit/lib/#" run.py || die
}

src_install() {
	waf-utils_src_install
	python_newscript run.py ${PN}
}
