# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/suspend/suspend-1.0.ebuild,v 1.9 2014/03/01 22:15:50 mgorny Exp $

EAPI=5

inherit autotools git-r3

DESCRIPTION="Userspace Software Suspend and S2Ram"
HOMEPAGE="http://suspend.sourceforge.net/"
EGIT_REPO_URI="git://github.com/bircoph/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="crypt fbsplash +lzo threads"

RDEPEND="
	dev-libs/libx86
	crypt? (
		>=dev-libs/libgcrypt-1.6.3:0[static-libs]
		dev-libs/libgpg-error[static-libs] )
	fbsplash? ( >=media-gfx/splashutils-1.5.4.4-r6 )
	lzo? ( >=dev-libs/lzo-2[static-libs] ) "
DEPEND="${RDEPEND}
	>=dev-lang/perl-5.10
	>=sys-apps/pciutils-2.2.4
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		$(use_enable crypt encrypt) \
		$(use_enable fbsplash) \
		$(use_enable lzo compress) \
		$(use_enable threads)
}

src_install() {
	dodir etc
	emake DESTDIR="${D}" install
	rm "${D}/usr/share/doc/${PF}"/COPYING* || die
}

pkg_postinst() {
	elog "In order to make this package work with genkernel see:"
	elog "http://bugs.gentoo.org/show_bug.cgi?id=156445"
}
