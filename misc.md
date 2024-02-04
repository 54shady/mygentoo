## Misc

### Linux Find Out Virtual Memory PAGESIZE(查询页表大小)

using getconf to get pagesize in bytes

	getconf PAGESIZE
	getconf PAGE_SIZE

### [Remount filesystem readonly](https://unix.stackexchange.com/questions/195010/remount-a-busy-disk-to-read-only-mode)

一般情况下有文件打开读写是无法挂载分区只读

但是可以尝试下面操作(不是一定可以成功)将对应的块设备设置成只读(有可能会报Permission denied)

	echo 1 >/sys/block/dm-4/ro
	echo 1 >/sys/block/sda/sda2/ro

或者使用sysrq的Emergency Remount(应该可以成功)

	echo u > /proc/sysrq-trigger

### 使用ldconfig建立动态库数据库

清除系统缓存的动态库数据库

	rm /etc/ld.so.cache
	or
	> /etc/ld.so.cache

建立新的缓存(根据配置文件/etc/ld.so.conf或/etc/ld.so.conf.d/目录下的文件)

	ldconfig -v

### DPI(Dots Per Inch)

[参考文章: Display size and DPI](https://wiki.archlinux.org/title/Xorg#Display_size_and_DPI)

[参考文章: HiDPI ](https://wiki.archlinux.org/title/HiDPI)

查看显示设备的DPI值

	xdpyinfo | grep -B 2 resolution

手动设置显示器的DPI

	xrandr --dpi <value>

xorg的默认值是96, 可设置为:

120 (25% higher), 144 (50% higher), 168 (75% higher), 192 (100% higher)

修改后会使用到DPI来设置显示的程序(比如使用了gtk的goldendict, 状态栏显示框,托盘右键菜单)

鼠标的DPI(假设event4对应鼠标)

	udevadm info /dev/input/event4  | grep MOUSE_DPI
	E: ID_INPUT_MOUSE=1
	E: MOUSE_DPI=1000@125

鼠标的DPI表示鼠标物理移动一英寸,光标在屏幕上移动了多少个像素点

对于一个分辨率1920x1080的显示器,上述鼠标从屏幕最左移动到最右需要移动的距离为

	1英寸= 2.54厘米
	1920/1000 = 1.92英寸 = 4.8768厘米

### 设置鼠标移动快慢

[libinput: Pointer acceleration](https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html#ptraccel-linear)

[ArchWiki: mouse acceleration](https://wiki.archlinux.org/title/Mouse_acceleration)

查看输入设备(比如下面的USB 鼠标)

	xinput --list
	⎡ Virtual core pointer                          id=2    [master pointer  (3)]
	⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
	⎜   ↳ PixArt Dell MS116 USB Optical Mouse       id=11   [slave  pointer  (2)]
	⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
		↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]

查看鼠标属性(字符串名字也可以用id值代替)

	xinput --list-props "pointer:PixArt Dell MS116 USB Optical Mouse"
	xinput --list-props 11

设置鼠标移动加快

	xinput --set-prop "pointer:PixArt Dell MS116 USB Optical Mouse" "libinput Accel Speed" +1.0

设置鼠标移动减慢

	xinput --set-prop "pointer:PixArt Dell MS116 USB Optical Mouse" "libinput Accel Speed" -1.0

设置默认速度

	xinput --set-prop "pointer:PixArt Dell MS116 USB Optical Mouse" "libinput Accel Speed" 0

### gentoo 清除dns

重启udhcpc(下面系统中有eth0和wlan0两张网卡)

	ps aux | grep udhcpc

	root      2520  0.0  0.0   3828   156 ?        Ss   14:36   0:00 /bin/busybox udhcpc -x hostname:mygentoo --interface=eth0 --now --script=/lib/netifrc/sh/udhcpc-hook.sh --pidfile=/run/udhcpc-eth0.pid
	root      8697  0.0  0.0   3828   152 ?        Ss   15:24   0:00 /bin/busybox udhcpc -x hostname:mygetnoo --interface=wlan0 --now --script=/lib/netifrc/sh/udhcpc-hook.sh --pidfile=/run/udhcpc-wlan0.pid

	sudo rc-service net.eth0 restart
	sudo rc-service net.wlan0 restart

### Nmap 查看端口是否开放

查看对应主机是否开放端口

	nmap [-v] <ip> [-p <port>]

比如查看是否开放3389端口

	$ nmap -Pn -v <ip> -p 3389
	PORT     STATE SERVICE
	3389/tcp open  ms-wbt-server (端口已开)

	$ nmap -Pn -v <ip> -p 3389
	PORT     STATE    SERVICE
	3389/tcp filtered ms-wbt-server (端口未开)

### 在终端里插入表情包(insert color emoji in terminal)

    ctrl+shift+u + unicode
    ctrl+shift+u + 1fxxx

### 双网卡(内外网同时通信)

[Openrc, Netifrc](https://wiki.gentoo.org/wiki/Netifrc)

- 有线网卡eth0作为内网通信的网卡,网关(178.2.10.1)
- 无线网卡wlan0作为外网通信的网卡,网关(192.168.8.8)

外网网卡配置

	route add -net 0.0.0.0/0 wlan0
	route add -net 0.0.0.0/0 gw 192.168.8.8

内网网卡配置(内网网段178)

	route add -net 178.0.0.0/8 eth0
	route add -net 178.0.0.0/8 gw 178.2.10.1

最终看到的路由情况如下

	default via 192.168.8.8 dev wlan0
	default dev wlan0 scope link
	178.0.0.0/8 via 178.2.10.1 dev eth0
	178.0.0.0/8 dev eth0 scope link
	178.2.10.0/24 dev eth0 proto kernel scope link src 178.2.10.101
	192.168.8.0/24 dev wlan0 proto kernel scope link src 192.168.8.48

在系统中配置上诉路由表(修改文件/etc/conf.d/net)

	config_wlan0="dhcp"
	config_eth0="dhcp"
	metric_eth0="0"
	metric_wlan0="0"
	routes_eth0="178.0.0.0/8 via 178.2.10.1"

在gentoo openrc系统中是通过busybox的udhcpc来配置路由的

	ps aux | grep udhcpc
	/bin/busybox udhcpc -x --interface=wlan0 --now --script=/lib/netifrc/sh/udhcpc-hook.sh ...

### 自动挂载网络共享

假设在/etc/fstab里有如下内容

	//192.168.1.123/sharedir  /mnt/share	cifs defaults,iocharset=utf8,uid=1000,gid=1000,rw,dir_mode=0777,file_mode=0777,username=gentoo,password=pwd_goes_here

需要开机自动挂载该远程共享目录到本地
挂载网络文件的脚本为/etc/init.d/netmount
将该脚本启动级别改为boot即可

	rc-update add netmount boot

### umount busy

假设/dev/sda8 挂在到了/mnt

卸载的时候发现设备忙

用fuser查看是什么在使用导致无法正常卸载

	# umount /dev/sda8
	umount: /mnt: target is busy
	(In some cases useful info about processes that use the device is found by lsof(8) or fuser(1).)

	# fuser -u -a -i -m -v /mnt
	USER        PID ACCESS COMMAND
	/mnt:                root     kernel mount (root)/mnt
				 root       5618 ..c.. (root)adb

发现是adb导致的, 查看adb程序确实在运行

	ps aux | grep adb
	root      5618  0.0  0.0 170360  3168 ?        Sl   Jan30   0:39 adb -P 5037 fork-server server
	root     21244  0.0  0.0  15824  2504 pts/3    S+   14:40   0:00 grep --colour=auto adb

停止ADB程序之后就可以正常卸载了

	# adb kill-server

### gcc-config: Active gcc profile is invalid

Gentoo软件安装错误,提示

	gcc-config: Active gcc profile is invalid

解决方法,列出可用的profile

	gcc-config -l
	gcc-config: Active gcc profile is invalid!
	[1] x86_64-pc-linux-gnu-4.9.3

显示当前使用的profile

	gcc-config -c
	gcc-config: Active gcc profile is invalid!
	[1] x86_64-pc-linux-gnu-4.9.3

设置profile

	gcc-config x86_64-pc-linux-gnu-4.9.3

### GRUB2添加WINDOWS启动

在/etc/grub.d/40_custom里添加下面内容

	menuentry "Widnwos 8" {
		insmod ntfs
		set root=(hd0,1)
		chainloader +1
		boot
	}

### konsole添加monaco字体

把MONACO.TTF字体文件放到/usr/share/fonts/下

创建一个konsole的配置文件即可

~/.kde4/share/apps/konsole/MonacoFont.profile

内容如下:

	[Appearance]
	ColorScheme=Solarized
	Font=Monaco,18,-1,5,50,0,0,0,0,0

	[General]
	Name=MonacoFont
	Parent=FALLBACK/
	ShowTerminalSizeHint=false

	[Scrolling]
	ScrollBarPosition=2

关掉所有konsole后重启就可以了

### 普通用户可读root用户挂在的磁盘

root用户挂在windows盘

	mount -t ntfs -o umask=000 /dev/sda1 /mnt/

其中/dev/sda1是安装在windows下的ntfs格式的C盘,之后普通用户就可读

### gentoo对linux目录结构的解释

```shell
/bin: Boot-critical applications关键启动程序
/etc: System administrator controlled configuration files系统配置文件
/lib: Boot-critical libraries关键启动库
/opt: Binary-only applications.安装的纯二进制程序
/sbin: System administrator boot-critical applications系统关键启动程序
/tmp: Temporary data临时数据
/usr: General applications普通程序
/usr/bin: Applications普通应用
/usr/lib: Libraries普通库
/usr/local: Non-portage applications. Ebuilds must not install here.使用非portage安装的二进制程序
/usr/sbin: Non-system-critical system administrator applications非系统关键程序
/usr/share: Architecture independent application data and documentation架构相关的数据和文档
/var: Program generated data程序运行是产生的数据
/var/cache: Long term data which can be regenerated
/var/lib: General application generated data
/var/log: Log files

Where possible, we prefer to put non-boot-critical applications in /usr rather than /. If a program is not needed in the boot process until after filesystems are mounted then it generally does not belong on /.
在文件系统挂在后才用到的程序应该放在/usr下而不是/下

Any binary which links against a library under /usr must itself go into /usr (or possibly /opt).

The /opt top-level should only be used for binary-only applications. Binary-only applications must not be installed outside of /opt.
单纯的二进制程序只能放到/opt下

The /usr/local hierarchy is for non-portage software. Ebuilds must not attempt to put anything in here.
/usr/local里的程序是使用非portage安装的软件,比如手动下载源码包后,手动配置和编译安装

The /usr/share directory is for architecture independent application data which is not modified at runtime.

Try to avoid installing unnecessary things into /etc — every file in there is additional work for the system administrator. In particular, non-text files and files that are not intended for system administrator usage should be moved to /usr/share.
/etc下只能有文本形式的系统配置文件,非系统配置文件需要放到/usr/share下
```

### 软件版本后缀意思

	Suffix 	Meaning
	_alpha 	Alpha release (earliest)
	_beta 	Beta release
	_pre 	Pre release
	_rc 	Release candidate
	(no suffix) 	Normal release
	_p 	Patch release

### 使用USB摄像头

安装了cheese后插入USB摄像头发现如下错误

	(cheese:26600): cheese-WARNING **: Device '/dev/video0' cannot capture at 640x480: /var/tmp/portage/media-plugins/gst-plugins-v4l2-1.4.5/work/gst-plugins-good-1.4.5/sys/v4l2/gstv4l2object.c(2845): gst_v4l2_object_set_format (): /GstCameraBin:camerabin/GstWrapperCameraBinSrc:camera_source/GstBin:bin35/GstV4l2Src:video_source:

	Call to S_FMT failed for YU12 @ 640x480: Input/output error

提示说无法支持640x480,这里用的摄像头是OV7740最大分辨率能够达到640x480

dmesg发现打开摄像头的时候恢报下面的错误

	uvcvideo: Failed to query (130) UVC probe control : -32 (exp. 26).

解决办法,修改UVC驱动的参数后发现可以正常使用

	echo 2 > /sys/module/uvcvideo/parameters/quirks

[参考文章](https://www.mail-archive.com/linux-uvc-devel@lists.berlios.de/msg03737.html)

### Fix Valgrind's must-be-redirected error in Gentoo

[参考链接](http://www.cnblogs.com/yangyingchao/archive/2013/12/20/3483712.html)

In order to fix this error, it is necessary to:

- enable the splitdebug feature (or rather: it is "recommended" to enable).
- enable debugging symbols for glibc.
- recompile sys-libs/glibc.

- 修改/etc/portage/make.conf添加splitdebug,应该也可以只修改glibc的

	FEATURES="$FEATURES splitdebug"

- 单独修改编译glibc时的编译选项(也可以在make.conf里配置成全局的)

Create the file /etc/portage/env/debug.conf and add:

	CFLAGS="${CFLAGS} -ggdb"
	CXXFLAGS="${CFLAGS} -ggdb"

创建/etc/portage/package.env/glibc添加如下内容

	sys-libs/glibc debug.conf

重新编译安装glibc

	emerge sys-libs/glibc

### [LVM usage](./lvm.md)

### TimeZone and Clock

[List of time zone abbreviations](https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations)

check time zone on linux(下面是东八区)

	date +"%Z %z"
	CST +0800

refer the link above for CST mean which is

	CST	China Standard Time	UTC+08

所以知道localtime = utc + timezone的时间差值

即date显示的就是localtime,等于utc时间加上东八区时间

如下是配置东八区后的查询得到的localtime

	# timedatectl
		  Local time: Thu 2023-07-13 16:20:46 CST
	  Universal time: Thu 2023-07-13 08:20:46 UTC
			RTC time: Thu 2023-07-13 16:20:48
		   Time zone: Asia/Shanghai (CST, +0800)
		 NTP enabled: yes
	NTP synchronized: yes
	 RTC in local TZ: yes
		  DST active: n/a

将utc时间写入到rtc时钟中,rtc会同步utc的时间

	# timedatectl set-local-rtc 0
	# timedatectl
		  Local time: Thu 2023-07-13 16:32:35 CST
	  Universal time: Thu 2023-07-13 08:32:35 UTC
			RTC time: Thu 2023-07-13 08:32:35
		   Time zone: Asia/Shanghai (CST, +0800)
		 NTP enabled: yes
	NTP synchronized: yes
	 RTC in local TZ: no
		  DST active: n/a

取消rtc同步utc

	# timedatectl set-local-rtc 1
	# timedatectl
		  Local time: Thu 2023-07-13 16:34:06 CST
	  Universal time: Thu 2023-07-13 08:34:06 UTC
			RTC time: Thu 2023-07-13 16:34:06
		   Time zone: Asia/Shanghai (CST, +0800)
		 NTP enabled: yes
	NTP synchronized: yes
	 RTC in local TZ: yes
		  DST active: n/a

在一些发行版本中可以通过下面方法来设置时区

	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

查看但前系统使用的时钟源和可用的时钟源

	cat /sys/devices/system/clocksource/clocksource0/current_clocksource

	cat /sys/devices/system/clocksource/clocksource0/available_clocksource
		tsc hpet acpi_pm

### 普通用户使用sudo启动应用程序无法打开图形界面

比如使用sudo qemu-system-x86_64时遇到错误(无法启动图形)

第一个问题: Authorization required, but no authorization protocol specified

	xhost + local:

第二个问题: gtk initialization failed

	export DISPLAY=:0

### ssh客户端提示:System is booting up. See pam_nologin(8)

需要修改服务端配置文件(/etc/pam.d/sshd)将包含pam_nologin.so这行注释掉

	sed -i -r 's/^(.*pam_nologin.so)/#\1/' /etc/pam.d/sshd

### 日期和秒数之间的转换(second2date, date2second)

[Get epoch time with trace-cmd](https://unix.stackexchange.com/questions/329742/how-to-get-epoch-time-with-trace-cmd-frontend-for-ftrace)

[timestamp online](https://timestamp.online/)

将-d指定的日期(这里用系统启动的日期)转换成1970来的秒数

	date -d `uptime -s` +"%s"

将-d指定的从1970年来的秒数(这里假设是1702018167)转成日期格式

	date -d @1702018167 +"%Y-%m-%d %H:%M:%S"

查看dmesg是默认打印的是系统开机后的秒数和微妙如下

	[365906.100210] usb 1-7: SerialNumber: 923QEDUM2263B

可以通过dmesg -T来查看日期格式

	[Fri Dec  8 14:49:26 2023] usb 1-7: SerialNumber: 923QEDUM2263B

通过上面步骤来计算dmesg里的时间(ftrace里的同理)

获取系统开机的秒数

	date -d "`uptime -s`" +"%s"
	1701652261

将日志中的时间加上开机的秒数

	echo "365906 + 1701652261" | bc
	1702018167

将秒数转成日期格式(因为没有加微妙数,所以偏差一秒)

	date -d @1702018167 +"%Y-%m-%d %H:%M:%S"
	2023-12-08 14:49:27

### Android phone on linux using scrcpy

1. enable the usb debug on android phone
2. on host run adb kill-server and adb shell to test it
3. run scrcpy on host (app-mobilephone/scrcpy)

### [Run feishu application](./feishu.md)
### [Config git sendemail](./git-send-mail.md)
