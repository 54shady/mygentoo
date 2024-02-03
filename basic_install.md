# 系统安装(We now going to binary and source mix mode)

## [制作启动u盘](usbboot.md)

## 分区

	/dev/sda1 ==> /boot
	/dev/sda2 ==> swap分区
	/dev/sda3 ==> /
	/dev/sda4 ==> /home

	mkfs.ext4 /dev/sda1
	mkfs.ext4 /dev/sda3
	mkfs.ext4 /dev/sda4

## 挂载相应分区,安装stage3

	mount /dev/sda3 /mnt/gentoo
	mkdir /mnt/gentoo/boot
	mount /dev/sda1 /mnt/gentoo/boot

	cd /mnt/gentoo
	tar Jxvf stage3-amd64-openrc-20240107T170309Z.tar.xz --xattrs

make.conf(/mnt/gentoo/etc/portage/make.conf)内容如下

	CFLAGS="-O2 -pipe"
	CXXFLAGS="${CFLAGS}"
	CHOST="x86_64-pc-linux-gnu"
	USE="bindist mmx sse sse2 dbus policykit udev udisks icu"
	PORTDIR="/usr/portage"
	DISTDIR="${PORTDIR}/distfiles"
	PKGDIR="${PORTDIR}/packages"
	GENTOO_MIRRORS="http://mirrors.sohu.com/gentoo/ http://mirrors.163.com/gentoo/"
	MAKEOPTS="-j8"

## /etc/fstab内容

	/dev/sda1       /boot   ext4    defaults,noatime        0       2
	/dev/sda2       none    swap    sw      0       0
	/dev/sda3       /       ext4    noatime 0       1
	/dev/sda4       /home   ext4    noatime 0       3

拷贝DNS信息

	cp -L /etc/resolv.conf /mnt/gentoo/etc/

## 安装portage

	tar Jxvf portage-20240111.tar.xz -C /mnt/gentoo/usr/

## 挂载必要目录

	mount -t proc proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev

	chroot /mnt/gentoo /bin/bash
	source /etc/profile

## select profile

	eselect profile set 1
	[1]   default/linux/amd64/17.1 (stable) *

## 下载编译内核代码

	emerge sys-kernel/gentoo-sources
	emerge sys-kernel/genkernel
	ln -s /usr/src/linux-6.1.67-gentoo /usr/src/linux
	genkernel all

## 安装grub

	emerge sys-boot/grub
    grub-install --target=x86_64-efi --efi-directory=/boot --removable
	grub-mkconfig -o /boot/grub/grub.cfg

## 配置主机名

	nano -w /etc/conf.d/hostname
	hostname="homepc"

## 配置网络文件(假设网卡是eth0/wlan0, 替换实际名字)

	/etc/conf.d/net

	config_eth0="dhcp"

	modules_wlan0="wpa_supplicant"
	config_wlan0="dhcp"

	cd /etc/init.d
	ln -s net.lo net.eth0
	rc-update add net.eth0 default

## 修改root密码

	passwd root

安装到这里最好重启系统后再安装后面的桌面环境

### 关于passwd

新版本pam的默认配置被修改为强口令

This system is configured to permit randomly generated passwords only

修改对应文件解决该问题

场景1:

文件/etc/pam.d/passwd中有对password的配置

	password    include     system-auth

对应的文件是/etc/pam.d/system-auth,其中有配置password的文件

	password    required    pam_passwdqc.so config=/etc/security/passwdqc.conf

其中passwdqc.conf(可以man passwdqc.conf)

	min=0,0,0,0,0
	max=40
	enforce=none #需要将enforce修改为none
	retry=3

场景2:(文件/etc/pam.d/passwd内容如下)

	@include common-password

说明其依赖写在当前目录下common-password文件,内容如下

	# here are the per-package modules (the "Primary" block)
	password        requisite                       pam_pwquality.so retry=3
	password        [success=1 default=ignore]      pam_unix.so use_authtok
	try_first_pass sha512
	# here's the fallback if no module succeeds
	password        requisite                       pam_deny.so
	# prime the stack with a positive return value if there isn't one already;
	# this avoids us returning an error just because nothing sets a success code
	# since the modules above will each just jump around
	password        required                        pam_permit.so

其中第一条中依赖pam_pwquality.so(这个对应文件/etc/security/pwquality.conf)

将其内容修改成如下就可以任意配置弱密码

	minlen = 0
	minclass = 0
	dictcheck = 0
	enforcing = 0

不需要安装图形界面的话安装到这里就可以了

## ~~安装KDE桌面环境~~

~~选择适当的profile~~

	eselect profile set 6

~~添加下面的几个USE~~

	USE＝"...dbus policykit udev udisks"

~~更新系统USE~~

	emerge --changed-use --deep @world

~~安装KDE组件~~

	emerge kde-apps/kdebase-meta

-------

安装xserver

	#emerge xorg-x11
	emerge xorg-server

安装X需要的组件

	emerge twm xclock xterm

测试X window是否安装成功

	startx

安装Display Manager(slim)

	emerge x11-misc/slim

X window Display Manager(/etc/conf.d/xdm)

	DISPLAYMANAGER="slim"

Slim的配置文件

	/etc/slim.conf

其中启动会话命令如下(可以配置使用.xinitrc)

	# login_cmd           exec /bin/sh - ~/.xinitrc %session
	# login_cmd           exec /bin/bash -login ~/.xinitrc %session
	login_cmd           exec /bin/bash -login /usr/share/slim/Xsession %session

添加开机默认启动

	rc-update add xdm default

修改KDE配置文件(/usr/share/config/kdm/kdmrc),让root可以登入

	AllowRootlogon = true

## ~~kconsole solarized~~

[参考链接](https://techoverflow.net/blog/2013/11/08/installing-konsole-solarized-theme/)

Just copy-n-paste this into your favourite shell:

	if [ -d ~/.kde4 ]; then
		wget -qO ~/.kde4/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
		wget -qO ~/.kde4/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
	else
		wget -qO ~/.kde/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
		wget -qO ~/.kde/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
	fi

After that, you only have to select the appropriate color profile (Settings —> Edit current profile —> Appearance).

让tmux自动加载.bashrc文件在.bash_profile文件里添加下面这句话

	. ~/.bashrc

## 添加新用户zeroway 默认组为users,附加组为adm,sys

	useradd  -m -g users -G adm,sys -s /bin/bash zeroway
	passwd zeroway

添加用户zeroway到video, docker组

	sudo gpasswd -M zeroway video
	sudo gpasswd -M zeroway docker

## 安装sudo

	emerge sudo

在/etc/sudoers中添加一行设置相应的用户比如

	zeroway ALL=(ALL) ALL

sudo的时候能自动补全

	emerge bash-completion
	echo "complete -cf sudo" >> /home/mobz/.bashrc

## virtual box 安装

	emerge app-emulation/virtualbox-bin
	gpasswd -a zeroway vboxusers
	emerge -1 @module-rebuild
	modprobe vboxdrv

将虚拟机驱动模块加入到系统启动加载模块中

在/etc/conf.d/modules中添加下面一行

	modules="vboxdrv"

## Dbus & consolekit

添加dbus 和 consolekit 默认启动

解决开机警告：Warning: Cannot open ConsoleKit session: Unable to open session: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory.

	rc-update add dbus default
	rc-update add consolekit default

## NetworkManager(删除系统默认的网络管理,以太网卡名eth0)

	rc-update del net.eth0
	rm /etc/conf.d/net
	rm  /etc/init.d/net.eth0

安装NetworkManager和networkmanagement

	emerge net-misc/networkmanager
	emerge kde-misc/networkmanagement

之后需要添加相应的widget才可以看到有系统托盘出现

	rc-update add NetworkManager  default

## 安装字体和输入法等

	emerge wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts corefonts ttf-bitstream-vera
	emerge fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

在~/.xprofile里或~/.bashrc里添加如下内容

在每个用户目录下都要有这个才能使用输入法

	export XMODIFIERS="@im=fcitx"
	export QT_IM_MODULE=fcitx
	export GTK_IM_MODULE=fcitx
	eval "$(dbus-launch --sh-syntax --exit-with-session)"

有些应用无法弹出输入法框时通过诊断看看

	fcitx-diagnose

gtk2/gtk3/qt都有对应的安装包,比如qt5的应用(qutebrowser)需要安装下面的包

	app-i18n/fcitx-qt5

列出已安装的字体(使能一个字体)

    eselect fontconfig list
    eselect fontconfig enable 911

## 设置时区和区域

查看可用的时区

	ls /usr/share/zoneinfo

OpenRC设置时区

	echo 'Asia/Chongqing' > /etc/timezone
	emerge --config sys-libs/timezone-data

ntp同步时间

	emerge net-misc/ntp
    ntpdate -b -u 0.gentoo.pool.ntp.org

设置locale(/etc/locale.gen 中添加下面内容):

	en_US ISO-8859-1
	en_US.UTF-8 UTF-8
	zh_CN GB18030
	zh_CN.GBK GBK
	zh_CN.GB2312 GB2312
	zh_CN.UTF-8 UTF-8

保存执行locale-gen

	locale-gen

在/etc/env.d/100i18n中添加如下内容

	LANG=en_US.UTF-8
	LC_CTYPE=zh_CN.UTF-8
	LC_NUMERIC="en_US.UTF-8"
	LC_TIME="en_US.UTF-8"
	LC_COLLATE="en_US.UTF-8"
	LC_MONETARY="en_US.UTF-8"
	LC_MESSAGES="en_US.UTF-8"
	LC_PAPER="en_US.UTF-8"
	LC_NAME="en_US.UTF-8"
	LC_ADDRESS="en_US.UTF-8"
	LC_TELEPHONE="en_US.UTF-8"
	LC_MEASUREMENT="en_US.UTF-8"
	LC_IDENTIFICATION="en_US.UTF-8"

安装完成后重启添加pinyin输入法

## Desktop Manager设置

配置文件

	/etc/conf.d/xdm

指定使用什么作为Display Manager[ slim | xdm | gdm | kdm | gpe | entrance ]

如果是

	DISPLAYMANAGER="xdm"

则需要将xdm添加到默认启动项里

	rc-update xdm default

如果是

	DISPLAYMANAGER="slim"

则会执行~/.xsession中的内容(比如下面)

	exec startkde

添加可执行权限

	chmod u+x ~/.xsession

也需要将xdm添加到默认启动项里

	rc-update add xdm default
