# [Debugging](https://wiki.gentoo.org/wiki/Debugging)

创建文件/etc/portage/env/debugsyms 内容如下

	CFLAGS="${CFLAGS} -ggdb3"
	CXXFLAGS="${CXXFLAGS} -ggdb3"
	# nostrip is disabled here because it negates splitdebug
	FEATURES="${FEATURES} splitdebug compressdebug -nostrip"

创建文件/etc/portage/env/installsources 内容如下

	FEATURES="${FEATURES} installsources"

安装debugedit和gdb

	emerge dev-util/debugedit sys-devel/gdb

将需要添加源码和调试符号的软件填入/etc/portage/package.env(比如添加glibc)

	sys-libs/glibc debugsyms installsources

调试代码在

	/usr/src/debug/sys-libs/glibc-2.38-r9/glibc-2.38
