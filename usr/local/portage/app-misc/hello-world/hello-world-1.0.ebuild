EAPI=6

DESCRIPTION="A classical example to use when starting on something new"
HOMEPAGE="http://wiki.gentoo.org/index.php?title=Basic_guide_to_write_Gentoo_Ebuilds"
SRC_URI="file:///usr/portage/distfiles/hello-world-1.0.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

src_compile() {
	emake
}

src_install() {
    dobin hello-world
}
