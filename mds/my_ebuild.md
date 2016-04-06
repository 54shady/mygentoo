```shell
如何编写一个gentoo的ebuild
可以参考官网上的例子,这里多写点内容

1. 在localoverlay里创建相应的ebuild文件
创建/usr/local/portage/app-misc/hello-world/hello-world-1.0.ebuild文件内容如下
其中SRC_URI这里用的是本地的一个文件

hello-world-1.0.ebuild内容:
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

2. 指定我们的源码路径,这里用的是本地的文件
hello-world-1.0.tar.gz里包含的文件如下:
hello-world-1.0/hello.c
hello-world-1.0/Makefile

hello.c内容:
#include <stdio.h>

int main(int argc, char **argv)
{
	printf("hello my first ebuild\n");
	return 0;
}

Makefile内容:
all:hello.c
	gcc -o hello-world hello.c

把这两个文件打包后放到指定目录即可
tar czvf hello-world-1.0.tar.gz hello-world-1.0/*

3. 生成相应的Manifest文件
ebuild /usr/local/portage/app-misc/hello-world/hello-world-1.0.ebuild manifest

4. 测试安装软件:
emerge app-misc/hello-world

5. 执行软件:
hello-world
```
