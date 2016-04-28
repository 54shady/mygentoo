```shell
使用gentoo搭建嵌入式开发环境
可以参考gentoo官网wiki
https://wiki.gentoo.org/wiki/Cross_build_environment
https://wiki.gentoo.org/wiki/Embedded_Handbook/General/Creating_a_cross-compiler

安装相应的交叉编译工具链(以Freescale IMX6处理器为例)
crossdev -S -P -v -t armv7a-hardfloat-linux-gnueabihf

测试安装好的交叉编译工具
编写一个简单的C测试程序,这里不贴出代码
后面需要跟上-static选项这里暂时不知道如何去掉这个选项
armv7a-hardfloat-linux-gnueabihf-gcc hello.c -static

安装完成后会生成如下目录作为交叉编译的目录(buildroot)
可以把这个目录制作成为一个rootfs
/usr/armv7a-hardfloat-linux-gnueabihf

配置相应的profile
cd /usr/armv7a-hardfloat-linux-gnueabihf/etc/portage/
rm make.profile
ln -s /usr/portage/profiles/default/linux/arm/13.0/armv7a make.profile

使用封装后的emerge安装软件，比如安装tslib
emerge-armv7a-hardfloat-linux-gnueabihf -v x11-libs/tslib

编译完成后会把软件安装在下面的buildroot中
/usr/armv7a-hardfloat-linux-gnueabihf/usr/bin

想给开发板编译一个busybox
emerge-armv7a-hardfloat-linux-gnueabihf -v sys-apps/busybox
adb push  /usr/armv7a-hardfloat-linux-gnueabihf/bin/busybox /

可以看到编译出来的busybox是包含静态库的
emerge-armv7a-hardfloat-linux-gnueabihf --info busybox

遗留一个问题
在编译程序的时候需要编译成静态
否则会有No such file or directory的错误提示,暂时还不知道这个要如何处理
```
