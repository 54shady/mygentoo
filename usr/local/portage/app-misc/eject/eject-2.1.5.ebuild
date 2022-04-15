# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Eject is a program for ejecting removable media under software control."
HOMEPAGE="https://launchpad.net/eject/"
SRC_URI="https://launchpad.net/eject/main/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=

S=${WORKDIR}/${PN}

PATCHES=(
    "${FILESDIR}"/0001-Add-ysmacro-header-file-on-gentoo.patch
)

MAKEOPTS="${MAKEOPTS} V=1"

src_prepare() {
	default
}

src_configure() {
	./configure || die "error..."
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${ED}" install
}
