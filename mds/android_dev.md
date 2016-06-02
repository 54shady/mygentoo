```shell
编译android 5.1源代码的时候发现有下面的错误
out/host/linux-x86/bin/aapt: error while loading shared libraries: libz.so.1: cannot open shared object file: No such file or directory

由于ARM是32位的，编译到时候要用到32位到库文件：
而我用到gentoo linux是64位到系统，系统到默认库是64位的
ls -l /usr/lib
lrwxrwxrwx 1 root root 5 May 26 01:19 /usr/lib -> lib64

先找到上面编译错误时需要用的库是属于那个软件包的：
equery b libz.so
sys-libs/zlib-1.2.8-r1 (/usr/lib64/libz.so)

查看这个软件包编译安装到时候用到use是什么，发现没有支持32位
equery u sys-libs/zlib
    - - abi_x86_32  : 32-bit (x86) libraries

	修改use重新安装即可
	在USES里添加
	# need by android 32bit lib
	sys-libs/zlib abi_x86_32
```
