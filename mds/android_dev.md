```shell
1. 
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

2. iperf测试wifi网卡性能
解压iperf-project.zip,拷贝iperf到android目录下的external里
其中ipef-project.zip源码是从http://www.cs.technion.ac.il/~sakogan/DSL/2011/projects/iperf/index.html下载的

2.1 编译给android使用的iperf:
mmm external/iperf/project/jni
adb push out/target/product/rk312x/system/xbin/iperf /system/xbin/

2.2 在gentoo上安装一个和安装在android上版本接近的iperf

在USE里添下面的USE使iperf支持多线程(/etc/portage/package.use/use)
=net-misc/iperf-2.0.5-r2 threads

gentoo默认安装高版本的iperf,需要手动mask掉(/etc/portage/package.mask/mask)
>=net-misc/iperf-3.0.11

2.3 测试(这里的测试平台是RK3128 android 5.1)
android:192.168.0.102
PC:192.168.0.171

下行测试:
PC$ iperf -c 192.168.0.102 -i 1 -t 60
android$ iperf -s

上行测试:
android$ iperf -c 192.168.0.102 -i 1 -t 60
PC$ iperf -s

3. gentoo 上使用adb 连接 FirePrime
使用到adb工具是编译生成的,在目录 out/host/linux-x86/bin/adb (这个文件)

sudo vi /etc/udev/rules.d/51-android.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="2207", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666"
重新插拔 USB 线，让 udev 规则生效

其中
2207是给rk3128使用的
12d1是给华为p9手机使用的
```
