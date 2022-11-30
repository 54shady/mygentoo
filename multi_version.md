## 同一个软件安装不同版本

查看软件media-libs/libpng有多少个版本

	eix media-libs/libpng

输出结果假设如下

可以看到该软件有3个slot其中(1.2)表示slot,每个slot中有对应一个软件版本

	[I] media-libs/libpng
		 Available versions:
		 (1.2)  1.2.56
		 (1.5)  1.5.26
		 (0)    1.6.19(0/16) ~1.6.20(0/16) ~1.6.21(0/16)
		   {apng neon static-libs ABI_MIPS="n32 n64 o32" ABI_PPC="32 64" ABI_S390="32 64" ABI_X86="32 64 x32"}
		 Installed versions:  1.2.56(1.2)(11:22:17 PM 12/11/2017)(ABI_MIPS="-n32 -n64 -o32" ABI_PPC="-32 -64" ABI_S390="-32 -64" ABI_X86="64 -32 -x32") 1.6.19(11:18:28 PM 12/11/2017)(apng -neon -static-libs ABI_MIPS="-n32 -n64 -o32" ABI_PPC="-32 -64" ABI_S390="-32 -64" ABI_X86="64 -32 -x32")
		 Homepage:            http://www.libpng.org/
		 Description:         Portable Network Graphics library

假设已经安装了1.6.19这个版本,现在想再安装1.2.56这个版本

只需要在emerge的时候跟上emerge package:slot即可

	emerge -v media-libs/libpng:1.2

