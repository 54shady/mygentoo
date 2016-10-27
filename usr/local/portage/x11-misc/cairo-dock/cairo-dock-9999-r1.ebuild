# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

# The ebuild depends on CMAKE and also the BZR revision control system
# which is used for pulling the source code from the LaunchPad repository
inherit cmake-utils bzr


# The aaunchpad repository where "cairo-dock" lives:
EBZR_REPO_URI="lp:cairo-dock-core"

# You can specify a certain revision from the repository here.
# Or comment it out to choose the latest ("live") revision.
#EBZR_REVISION="959"

DESCRIPTION="Cairo-dock is a fast, responsive, Mac OS X-like dock."
HOMEPAGE="https://launchpad.net/cairo-dock-core/"
# Next line is not needed because the BZR repository is specified further above
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="xcomposite"


# Installation instructions (from BZR source) and dependencies are listed here:
# http://glx-dock.org/ww_page.php?p=From%20BZR&lang=en

RDEPEND="
	dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libxml2
	gnome-base/librsvg
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	x11-libs/libXrender
	net-misc/curl
	x11-libs/pango
	xcomposite? (
		x11-libs/libXcomposite
		x11-libs/libXinerama
		x11-libs/libXtst
	)
"


DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext
"


pkg_setup()
{
	ewarn ""
	ewarn ""
	ewarn "You are installing from a LIVE EBUILD, NOT AN OFFICIAL RELEASE."
	ewarn "   Thus, it may FAIL to build properly."
	ewarn ""
	ewarn "This ebuild is not supported by a Gentoo developer."
	ewarn "   So, please do NOT report bugs to Gentoo's bugzilla."
	ewarn "   Instead, report all bugs to write2david@gmail.com"
	ewarn ""
	ewarn ""

}


src_prepare() {
	bzr_src_prepare
}



src_configure() {

    # Next line added because of the same issues/solutions reported on...
    # ... # https://bugs.launchpad.net/cairo-dock-plug-ins/+bug/922981
    # 
    # With a solution inspired on...
    # http://code.google.com/p/rion-overlay/source/browse/x11-misc/cairo-dock-plugins/cairo-dock-plugins-2.3.9999.ebuild?spec=svn71d4acbbb8c297b818ff886fb5dd434a6f54c377&r=71d4acbbb8c297b818ff886fb5dd434a6f54c377

    # These CMAKE variables are listed in the BZR installation instructions (link above)
    # Some more info...  http://www.cmake.org/Wiki/CMake_Useful_Variables


	# Adding the "-DLIB_SUFFIX" flag b/c https://bugs.launchpad.net/cairo-dock-core/+bug/1073734	


    mycmakeargs="${mycmakeargs} -DROOT_PREFIX=${D} -DCMAKE_INSTALL_PREFIX=/usr -DLIB_SUFFIX=" 
    cmake-utils_src_configure
}


pkg_postinst() {
	ewarn ""
	ewarn ""
	ewarn "You have installed from a LIVE EBUILD, NOT AN OFFICIAL RELEASE."
	ewarn "   Thus, it may FAIL to run properly."
	ewarn ""
	ewarn "This ebuild is not supported by a Gentoo developer."
	ewarn "   So, please do NOT report bugs to Gentoo's bugzilla."
	ewarn "   Instead, report all bugs to write2david@gmail.com"
	ewarn ""
	ewarn ""
}
