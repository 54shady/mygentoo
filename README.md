# All the stuffs about my gentoo linux

## 使用方法
	拷贝各个目录下的文件到相应的目录下
	etc <==> /etc
	user <==> /home/your_local_user_name or /root
	usr <==> /usr
	var <==> /var
	kde4 <==> ~/.kde4
	config <==> ~/.config

## 常用命令
	sudo emerge -uDN @world
	sudo emerge -c
	revdep-rebuild

## Branches

i56500 : [hs](https://github.com/54shady/hs)

i73700 : [ks](https://github.com/54shady/KS)

i76700kz170p : home

thinkpadE460 : [forelders](https://github.com/54shady/forelders)

===================================================================


## 系统安装

### 分区

	/dev/sda1 ==> /boot
	/dev/sda2 ==> swap分区
	/dev/sda3 ==> /
	/dev/sda4 ==> /home

	mkfs.ext4 /dev/sda1
	mkfs.ext4 /dev/sda3
	mkfs.ext4 /dev/sda4

### 挂载相应分区,安装stage3

	mount /dev/sda3 /mnt/gentoo
	mkdir /mnt/gentoo/boot
	mount /dev/sda1 /mnt/gentoo/boot

	cd /mnt/gentoo
	tar xvjpf stage3-*.tar.bz2 --xattrs

make.conf(/mnt/gentoo/etc/portage/make.conf)内容如下：

	CFLAGS="-O2 -pipe"
	CXXFLAGS="${CFLAGS}"
	CHOST="x86_64-pc-linux-gnu"
	USE="bindist mmx sse sse2 dbus policykit udev udisks icu"
	PORTDIR="/usr/portage"
	DISTDIR="${PORTDIR}/distfiles"
	PKGDIR="${PORTDIR}/packages"
	GENTOO_MIRRORS="http://mirrors.sohu.com/gentoo/ http://mirrors.163.com/gentoo/"
	MAKEOPTS="-j8"

### /etc/fstab内容

	/dev/sda1       /boot   ext4    defaults,noatime        0       2
	/dev/sda2       none    swap    sw      0       0
	/dev/sda3       /       ext4    noatime 0       1
	/dev/sda4       /home   ext4    noatime 0       3

拷贝DNS信息

	cp -L /etc/resolv.conf /mnt/gentoo/etc/

### 挂载必要目录

	mount -t proc proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev

	chroot /mnt/gentoo /bin/bash
	source /etc/profile

### 安装portage

先下载好portage的snapshot压缩包直接解压到/usr/

先使用profile 1

eselect profile set 1

[1]   default/linux/amd64/13.0


### 下载编译内核代码

	emerge -v sys-kernel/gentoo-sources
	emerge -v sys-kernel/genkernel
	genkernel all

### 安装grub

	emerge sys-boot/grub
	grub-install /dev/sda --target=i386-pc
	grub-mkconfig -o /boot/grub/grub.cfg

### 配置主机名

	nano -w /etc/conf.d/hostname
	hostname="zeroway"

### 配置网络文件

	/etc/conf.d/net
	config_eth0="dhcp"

	cd /etc/init.d
	ln -s net.lo net.eth0
	rc-update add net.eth0 default

### 修改root密码

	passwd root

安装到这里最好重启系统后再安装后面的桌面环境

不需要安装图形界面的话安装到这里就可以了

=============================================

### 安装KDE桌面环境

	eselect profile set 6

添加下面的几个USE

	USE＝"...dbus policykit udev udisks"
	emerge --changed-use --deep @world
	emerge kde-apps/kdebase-meta
	emerge xorg-x11
	emerge slim

	/etc/conf.d/xdm
	DISPLAYMANAGER="slim"
	rc-update add xdm default

修改KDE配置文件(/usr/share/config/kdm/kdmrc),让root可以登入

	AllowRootlogon = true

### kconsole solarized

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

### 添加新用户zeroway 默认组为users,附加组为adm,sys

	useradd  -m -g users -G adm,sys -s /bin/bash zeroway
	passwd zeroway

### 安装sudo

	emerge sudo

在/etc/sudoers中添加一行设置相应的用户比如

	zeroway ALL=(ALL) ALL

sudo的时候能自动补全

	emerge bash-completion
	echo "complete -cf sudo" >> /home/mobz/.bashrc

### virtual box 安装

	emerge app-emulation/virtualbox-bin
	gpasswd -a zeroway vboxusers
	emerge -1 @module-rebuild
	modprobe vboxdrv

将虚拟机驱动模块加入到系统启动加载模块中

在/etc/conf.d/modules中添加下面一行

	modules="vboxdrv"

### Dbus & consolekit

添加dbus 和 consolekit 默认启动

解决开机警告：Warning: Cannot open ConsoleKit session: Unable to open session: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory.

	rc-update add dbus default
	rc-update add consolekit default

### NetworkManager(删除系统默认的网络管理)

	rc-update del net.enp5s0
	rm /etc/conf.d/net
	rm  /etc/init.d/net.enp5s0

安装NetworkManager和networkmanagement

	emerge net-misc/networkmanager
	emerge kde-misc/networkmanagement

之后需要添加相应的widget才可以看到有系统托盘出现

	rc-update add NetworkManager  default

### 安装字体和输入法等

	emerge wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts corefonts ttf-bitstream-vera
	emerge fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

如果使用的是KDE桌面环境,需要在~/.xprofile里添加如下内容

在每个用户目录下都要有这个才能使用输入法

	export XMODIFIERS="@im=fcitx"
	export QT_IM_MODULE=fcitx
	export GTK_IM_MODULE=fcitx
	eval "$(dbus-launch --sh-syntax --exit-with-session)"

设置locale(/etc/locale.gen中添加下面内容):

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

### Desktop Manager设置

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

## 使用UEFI模式启动的电脑安装GENTOO

下面只说明差异部分

假设/dev/sda1就是EFI分区,那就让gentoo使用这个分区

使用刻录ubuntu14.04到u盘,这里借用ubuntu的刻录盘来进入到UEFI模式

[参考链接](http://jingyan.baidu.com/article/a378c960630e61b329283045.html)

使用UEFI模式启动,需要关掉secure boot功能

分区和挂载点:

sda4 ==> /home

sda5 ==> /

sda6 ==> swap

	mkfs.ext4 /dev/sda4
	mkfs.ext4 /dev/sda5
	mkswap /dev/sda6
	swapon  /dev/sda6

	mkdir /mnt/gentoo
	mount /dev/sda5 /mnt/gentoo/
	mkdir /mnt/gentoo/boot/efi -p

挂载EFI分区

	mount /dev/sda1 /mnt/gentoo/boot/efi

下面到操作要保证能成功的前提是启动到时候是UEFI模式启动的

安装grub支持EFI,这里指定的EFI目录就是挂载到sda1

	echo GRUB_PLATFORMS="efi-64" >> /etc/portage/make.conf
	emerge sys-boot/grub:2
	grub2-install  --target=x86_64-efi --efi-directory=/boot/efi
	grub2-mkconfig -o /boot/grub/grub.cfg
## 应用软件安装

### USBView

软件安装

	sudo emerge -v app-admin/usbview

因为该软件需要访问/sys/kernel/debug/usb目录需要root权限

但是使用root用户会有下面的错误

	(usbview:4377): Gtk-WARNING **: cannot open display: :0

需要在非root用户下执行

	$ xhost local:root

原因是root用户没有加入到zeroway访问X server的权限里

	$ sudo usbview 就可以执行了

### plantuml

安装

	sudo emerge -v media-gfx/plantuml

使用

	java -jar /usr/share/plantuml/lib/plantuml.jar sequenceDiagram.txt
	其中sequenceDiagram.txt内容如下
	@startuml
	Alice -> Bob: test
	@enduml

## 桌面环境配置(KDE)

### KDE win键设置

WIN键的设置

使用WIN+D来像WINDOWS一样显示桌面

System Settings > Shortcuts and Gestures > Global Keyboard Shortcuts > KDE component: KWin > Show Desktop

设置成win+d即可

WIN+e 绑定dolphin程序

CustomShortcuts里设置即可

根据字母在键盘排布位置对应桌面的位置

使用WIN+CTRL+q

KWin->Quick Tile Window to the Top Left

使用WIN+CTRL+a

KWin->Quick Tile Window to the Left

使用WIN+CTRL+z

KWin->Quick Tile Window to the Bottom Left

使用WIN+CTRL+p

KWin->Quick Tile Window to the Top Right

使用WIN+CTRL+l

KWin->Quick Tile Window to the Right

使用WIN+CTRL+m

KWin->Quick Tile Window to the Bottom Right

使用WIN+CTRL+o

KWin->Maxmize Window

使用WIN+CTRL+x

KWin->Minimize Window

### 安装声卡驱动相关

首先查看声卡驱动

lspci | grep -i audio

在内核中添加相关的驱动支持,确认下面这几个包都安装了

	media-sound/alsa-utils
	media-libs/alsa-lib

安装kmix

	emerge kde-apps/kmix

安装完后点击音量控制图标

勾选Autostart和Dock in system tray

以后开机就能看到该图标了

设置音量调节快捷键

WIN+PageUp音量增

WIN+PageDn音量减

WIN+Del	  静音

### 安装plank

使用localoverlay方法安装

	emerge x11-misc/plank

其中火狐会无法pin到plank上

在宿主目录下手动添加下面文件

/home/zeroway/.config/plank/dock1/launchers
内容如下:

	[PlankItemsDockItemPreferences]
	Launcher=file:///usr/share/applications/firefox-bin.desktop

### 安装suspend

发现用默认的gentoo portage安装会有冲突

所以就用localoverlay的方法安装

使用的Overlay: bircoph (layman)

	# layman -a bircoph
	# emerge sys-power/suspend

卸载upower

	emerge --unmerge sys-power/upower

安装pm utils

	emerge sys-power/upower-pm-utils

ctrl+alt+F7可以切换到图形登入界面

Suspend to disk with sys-power/pm-utils

配置SWAPFILE

用swapon -s 查看swap分区,假设是/dev/sda8

在/etc/default/grub文件里添加下面内容

	GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/sda8"

重新生成grub配置文件

	grub2-mkconfig -o /boot/grub/grub.cfg

更新initramfs

	genkernel --install initramfs

在/etc/pm/config.d/gentoo中添加下面的内容

	SLEEP_MODULE="kernel"

重启系统

	reboot

使用pm utils的工具测试,就可以suspend to disk

	pm-hibernate

也就是点击Hibernate的效果

会把当前电脑所有状态保存在SWAP分区中,之后待机

出发键盘任意键可以唤醒系统,唤醒过程和正常开机一样,只是进入系统后会回复到保存的地方

### 安装partitionmanager

软件安装

	emerge sys-block/partitionmanager

安装后需要使用root权限启动软件才能查看完整的磁盘信息

我使用的普通用户zeroway,所以要用sudo partitionmanager

但是发现提示下面的错误:

	partitionmanager: cannot connect to X server :0

原因是root用户没有加入到zeroway访问X server的权限里

只要添加就可以了

	xhost local:root

现在就能用sudo partitionmanager启动软件了

以后凡是需要有root权限的GUI程序都可以这样

例如porthole(portage图形安装方式)软件也是一样的

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

## git 服务器搭建

### 分区,只分了/boot / swap三个分区 (/etc/fstab内容如下)

	/dev/sda2       /boot   ext4    defaults,noatime        0       2
	/dev/sda3       none    swap    sw      0       0
	/dev/sda4       /       ext4    noatime 0       1

基本安装过程和上面一样,只不过没有安装图形界面

### git server 搭建

静态IP地址配置 (/etc/conf.d/net)

	config_enp1s0="192.168.7.100 netmask 255.255.255.0"
	routes_enp1s0="default via 192.168.7.1"
	dns_servers_enp1s0="192.168.7.1 8.8.8.8"

安装git

	emerge dev-vcs/git

添加git用户

	groupadd git
	useradd -m -g git -d /var/git -s /bin/bash git

编辑/etc/conf.d/git-daemon内容如下

	GIT_USER="git"
	GIT_GROUP="git"

启动相应服务

	/etc/init.d/git-daemon start

添加开机启动

	rc-update add git-daemon default

SSH keys添加到下面文件

在客户端执行

	ssh-keygen -t rsa

将客户端生成的id_rsa.pub里的内容拷贝到服务器上下面的文件里

	/var/git/.ssh/authorized_keys

服务器上创建仓库(在服务器上操作,ip:192.168.7.100)

	# su git
	$ cd /var/git
	$ mkdir /var/git/newproject.git
	$ cd /var/git/newproject.git
	$ git init --bare

在客户端(ip:192.168.7.101)上把要添加文件到刚才创建的仓库

	$ mkdir ~/newproject
	$ cd ~/newproject
	$ git init
	$ touch test
	$ git add test
	$ git config --global user.email "M_O_Bz@163.com"
	$ git config --global user.name "zeroway"
	$ git commit -m 'initial commit'
	$ git remote add origin git@192.168.7.100:/var/git/newproject.git
	$ git push origin master

在其他客户端(client)克隆该仓库

	git clone git@192.168.7.100:/newproject.git

Samba安装和配置

	sudo emerge -v net-fs/samba

拷贝一个配置文件,在此基础上修改

	sudo cp /etc/samba/smb.conf.default /etc/samba/smb.conf

添加用户并设置密码

	sudo smbpasswd -a zeroway

开启服务

	sudo /etc/init.d/samba start

设置某个目录为共享目录

在/etc/samba/smb.conf最后添加下面内容

	[myshare]
	comment = zeroway's share on gentoo
	path = /home/zeroway/Downloads
	valid users = zeroway
	browseable = yes
	guest ok = yes
	public = yes
	writable = no
	printable = no
	create mask = 0765

samba高级设置

单独为使用samba的用户设置一个组,该组成员不能通过终端登入,只能访问samba服务

新建一个samba组

	groupadd samba

添加一个hsdz的用户到该组(samba)

使用/bin/false作为shell,且不设置用户密码

	useradd -g samba -s /bin/false hsdz

注意:在/etc/samba/smb.conf里要添加这个用户访问权限

设置该用户samba访问密码

	smbpasswd -a hsdz

重启samba服务后即可访问

## 在同一台电脑上管理多个ssh key

在开发过程中存在同步内网和外网代码的情况,会存在需求切换ssh key的场景

假设有如下场景,本地电脑既需要从内网服务器下载代码,也需要从外网服务器下载代码

假设本地开发电脑IP 172.1.2.81

假设本地局域网内代码服务器IP 172.1.2.83

远程外网服务器地址www.rockchip.com.cn

在本地电脑上存在两个ssh key假设如下

	id_rsa.pub_code
	id_rsa_code

	id_rsa.pub_rk
	id_rsa_rk

id_rsa_code是用于和本地代码服务器通信的私钥

id_rsa_rk是用于和远程外网服务器通信的私钥

查看ssh key的代理

	ssh-add -l

若提示如下则表示系统代理没有任何key

	Could not open a connection to your authentication agent

开启系统代理

	exec ssh-agent bash

删除系统中的所有代理

	ssh-add -D

将需要使用的私钥添加到代理中

	ssh-add ~/.ssh/id_rsa_rk
	ssh-add ~/.ssh/id_rsa_code

将公钥添加到相应的远程服务器,这里不演示

在本地电脑添加ssh的配置文件(~/.ssh/config)

	# local ip 172.1.2.81
	# remote code server ip 172.1.2.83
	Host 172.1.2.83
	HostName 172.1.2.83
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_code
	user zeroway

	# rockchip
	Host rockchip
	HostName www.rockchip.com.cn
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_rk
	user zeroway

	# github
	Host github
	HostName https://github.com/54shady
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_code
	user linwei

对上面配置文件介个关键地方解释下

本地电脑上下载远程服务器是通过git
Host和HostName都需写为远程服务器ip

	git clone git@172.1.2.83:/code_path.git

对于外网的代码服务器,使用repo下载
在相应的代码的.repo/manifest.xml文件中

	<remote fetch="ssh://git@www.rockchip.com.cn/gerrit/" name="aosp"/>
	<remote fetch="ssh://git@www.rockchip.com.cn/gerrit/" name="rk"/>
	<remote fetch="ssh://git@www.rockchip.com.cn/repo/" name="stable"/>

其中的user需要填写对应的用户名,这里是zeroway

## aria2 + apache + yaaw 下载服务器搭建

[安装apache参考https://wiki.gentoo.org/wiki/Apache](https://wiki.gentoo.org/wiki/Apache)

使用的是gentoo的portage,没有使用第三方overlay,如果本地有第三方overlay可能在安装的时候会有错误

所有操作都使用root用户

安装aria2

	添加必要的USE
	echo "net-misc/aria2 bittorrent metalink" >> /etc/portage/package.use/use
	emerge -v net-misc/aria2

配置aria2

	mkdir -p /etc/aria2/
	touch /etc/aria2/aria2.session
	添加/etc/aria2/aria2.conf

[aria2.conf内容https://github.com/54shady/mygentoo/blob/i56500/etc/aria2/aria2.conf](https://github.com/54shady/mygentoo/blob/i56500/etc/aria2/aria2.conf)

安装apache

	emerge -v www-servers/apache

在/etc/hosts中确保有下面的内容(其中zeroway是hostname)

	127.0.0.1 zeroway

启动服务器

	sudo /etc/init.d/apache2 start

测试apache是否安装成功,在浏览器里输入服务器IP(192.168.7.103)就可以访问了

修改apache默认访问目录

从apache的配置文件/etc/apache2/vhosts.d/default_vhost.include
中可以知道默认的访问目录是/var/www/localhost/htdocs
这里修改为如下:

	DocumentRoot "/var/www/html"
	<Directory "/var/www/html">

安装yaaw

	git clone https://github.com/binux/yaaw.git /var/www/html

启动aria2

	aria2c --conf-path=/etc/aria2/aria2.conf

再次在浏览器中访问测试是否安装成功

## linux开发环境搭建

### TFTP服务器搭建

在gentoo上安装tftp软件

  sudo emerge -v net-ftp/atftp

配置文件(/etc/conf.d/atftp)内容如下

	# Config file for tftp server
	TFTPD_ROOT="/home/zeroway/github/matrix"
	TFTPD_OPTS="--daemon --user nobody --group nobody"

开启tftp服务(服务器IP:192.168.1.100)

	/etc/init.d/atftp start

在开发板上使用tftp(比如从tftp服务器上获取libfahw.so)

	tftp -g 192.168.1.100 -r lib/libfahw.so
	cp libfahw.so lib/

拷贝一个测试程序

	tftp -g 192.168.1.100 -r demo/matrix-pwm/matrix-pwm
	chmod +x matrix-pwm
	./matrix-pwm

### NFS服务器

内核配置(gentoo内核配置NFS相关选项参考官网即可)

安装相应的工具

	emerge --ask net-fs/nfs-utils

创建相关的目录

	mkdir /export
	mkdir /export/nfs_rootfs
	mount --bind /home/zeroway/armlinux/rootfs_for_3.4.2 /export/nfs_rootfs

在/etc/exports文件中添加如下内容

	/export/nfs_rootfs *(rw,sync,no_root_squash)

修改了该文件后需要执行

	exportfs -rv

配置/etc/conf.d/nfs这个文件,支持NFS版本在这里设置

	OPTS_RPC_NFSD="8 -V 2 -V 3 -V 4 -V 4.1"

gentoo上先测试是否可以挂载

	/etc/init.d/nfs start

使用VER2

	mount -t nfs -o nolock,vers=2 192.168.1.101:/export/nfs_rootfs /mnt

使用VER4

	mount -t nfs -o nolock,vers=4 192.168.1.101:/export/nfs_rootfs /mnt

在开发板上设置相关的参数

其中:gentoo_pc_ip=192.168.1.101,开发板:192.168.1.230

	set machid 7cf ;set bootargs console=ttySAC0,115200 root=/dev/nfs nfsroot=192.168.1.101:/export/nfs_rootfs ip=192.168.1.230:192.168.1.101:192.168.1.1:255.255.255.0::eth0:off ;nfs 30000000 192.168.1.101:/export/nfs_rootfs/uImage;bootm 30000000

开机启动相关配置

在/etc/fstab中添加下面内容

	/home/zeroway/armlinux/rootfs_for_3.4.2 /export/nfs_rootfs none bind 0 0

添加开机启动

	rc-update add nfs default

### 环境变量设置

全局环境变量配置

在/etc/env.d/添加一个文件,名字随意,自己知道是给什么软件配置的就可以

由于是给arm-linux-gcc 4.3.2版本配置,所以我写成了432arm-linux-gcc

里面写入相关的路径,比如交叉编译工具在/opt/toolschain/usr/local/arm/4.3.2/bin

432arm-linux-gcc文件内容如下

	PATH="/opt/toolschain/usr/local/arm/4.3.2/bin"
	ROOTPATH="/opt/toolschain/usr/local/arm/4.3.2/bin"

之后执行下面的命令就可以更新环境变量了

	env-update && source /etc/profile

局部环境变量配置

在.bashrc里添加或是export配置PATH

### 32位库文件问题

编译android 5.1源代码的时候发现有下面的错误

	out/host/linux-x86/bin/aapt: error while loading shared libraries: libz.so.1: cannot open shared object file: No such file or directory

由于该ARM是32位的,编译到时候要用到32位到库文件

而我用到gentoo linux是64位到系统,系统到默认库是64位的

	ls -l /usr/lib
	lrwxrwxrwx 1 root root 5 May 26 01:19 /usr/lib -> lib64

先找到上面编译错误时需要用的库是属于那个软件包的

	equery b libz.so
	sys-libs/zlib-1.2.8-r1 (/usr/lib64/libz.so)

查看这个软件包编译安装到时候用到use是什么,发现没有支持32位

	equery u sys-libs/zlib
		- - abi_x86_32  : 32-bit (x86) libraries

修改use重新安装即可,在USES里添加

	# need by android 32bit lib
	sys-libs/zlib abi_x86_32

### adb fastboot dnw等本地非root用户工具

在宿主目录下创建一个目录,这里假设是~/Tools

这个目录下放的都是本用户的二进制工具

把adb fastboot dnw dtc mkimage等工具放到这个目录下

因为fastboot dnw这些工具需要sudo 权限才可以执行

在.bashrc里export 这个路径

	export PATH=$PATH:~/Tools

修改/etc/sudoers,添加下面内容

	Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/zeroway/Tools"

上面把/home/zeroway/Tools这个目录添加到sudo搜索工具的目录

### 挂载WINDOWS共享目录

假设WINDOWS(192.168.1.123)共享目录名为WinShare,挂载目录/mnt/test(fstab如下)

	//192.168.1.123/WinShare  /mnt/test  cifs defaults,iocharset=utf8,uid=1000,gid=1000,rw,dir_mode=0777,file_mode=0777,username=AAA,password=BBB

## Local overlay使用

local overlay的用法,官网上也有详细说明,这里只是个人积累

用的时候需要修改源码后再安装软件,这里就可以用local overlay的方法来操作

### 例子(改造grep)

默认grep出来的结果是用":"分割的

现在想把这个":"分割号改成"+"号,以便可以用vi直接打开相应的文件和对应的行

创建一个本地的overlay,我这里取名叫localoverlay

	root # mkdir -p /usr/local/portage/{metadata,profiles}
	root # echo 'mobzoverlay' > /usr/local/portage/profiles/repo_name
	root # echo 'masters = gentoo' > /usr/local/portage/metadata/layout.conf
	root # chown -R portage:portage /usr/local/portage

cat /etc/portage/repos.conf/local.conf

	[localoverlay]
	location = /usr/local/portage
	masters = gentoo
	auto-sync = no

创建相关目录

	root # mkdir -p /usr/local/portage/sys-apps/grep

拷贝ebuild文件

	root # cp /usr/portage/sys-apps/grep/grep-2.21-r1.ebuild  /usr/local/portage/sys-apps/grep/

设置权限

	root # chown -R portage:portage /usr/local/portage

生成manifest并下载依赖文件

	root # pushd /usr/local/portage/sys-apps/grep
	root # repoman manifest
	root # popd

或者执行下面命令

	root # ebuild /usr/local/portage/sys-apps/grep/grep-2.21-r1.ebuild manifest

注意:每次修改了ebuild文件后就需要重新生成manifest文件

其中我在原有的ebuild文件里添加下面第二行打mygrep.patch的代码

	epatch "${DISTDIR}/${P}-heap_buffer_overrun.patch"
	epatch -p1 -R "/usr/portage/distfiles/mygrep.patch"

其中patch文件制作可以用git也可以直接用diff

	git diff commit1 commit2 > mygrep.patch
	diff -aurNp dir1 dir2 > mygrep.patch

安装软件的时候可以指定用哪个repo或是overlay

安装系统的portage里的grep

	emerge grep::gentoo

安装本地mobzoverlay里的grep

	emerge grep::localoverlay

### 例子(安装高版本pandoc)

由于碰到pandoc的版本比较低,现在需要更像高版本的

可以用一个overlay直接装,操作大概如下

	layman -a NewOverLayName
	emerge pandoc

这里不用上面这样的办法,上面方法需要下载一个完整的overlay,这里不想这样

所以还是和local overlay一样,只要有ebuild文件即可

首先需要到到下面这个网站上查找需要的ebuild文件

[http://gpo.zugaina.org/Overlays/bgo-overlay](http://gpo.zugaina.org/Overlays/bgo-overlay)

这里需要安装pandoc所以搜索pandoc

下载需要的ebuild文件到指定目录下

这里指定为/usr/local/portage/app-text/pandoc

生成相应的manifest文件,这个过程还会下载相应的包

	pushd /usr/local/portage/app-text/pandoc
	repoman manifest
	popd

由于下载的包是不稳定版本,没有被gentoo官方unmask

所以这里需要在accept里添加下面的内容

在/etc/portage/package.accept_keywords里添加下面的内容

	>=app-text/pandoc-1.16.0.2 ~amd64

之后就可以emerge pandoc了,不过这里由于依赖关系

所以还需要安装两外两个包,安装的时候就知道了,是cmark和pandoc-types

下载cmark的ebuild文件放到/usr/local/portage/dev-haskell/cmark下

下载pandoc-types的ebuild文件放到/usr/local/portage/dev-haskell/pandoc-types下

在/etc/portage/package.accept_keywords里添加下面的内容

	>=dev-haskell/cmark-0.5.1 ~adm64
	>=dev-haskell/pandoc-types-1.16.1 ~amd64

之后就可以安装高版本的pandoc了,解决了低版本无法识别markdown里index的问题

### 例子3(修改本地软件)

比如现在想要调试或修改一个应用软件,这里用kdiff3作为例子

首先可以安装正常的方法先安装或是通过emerge指定只下载kdiff3的源码

解压源码,根据个人需要修改源码,重新打包源码,比如名字为kdiff3-0.9.98.tar.gz

在local overlay 里拷贝一份kdiff3的ebuild文件,修改其中的SRC_URI

	SRC_URI="file:///usr/portage/distfiles/kdiff3-0.9.98.tar.gz"

这样做的目的是为了不重新下载而是使用本地修改过的代码

重新生成manifest

	ebuild /usr/local/portage/kde-misc/kdiff3/kdiff3-0.9.98.ebuild manifest

安装修改过的kdiff3,这里需要指定使用的是哪个overlay,这里使用的是上面创建的名为localoverlay的overlay

	emerge -v kdiff3::localoverlay

## 更新内核

下载最新内核代码,这里用的是4.4.4的内核代码

	echo ">=sys-kernel/gentoo-sources-4.4.4 ~amd64" >>  /etc/portage/package.accept_keywords
	emerge -v  sys-kernel/gentoo-sources

选择相应的代码(查看系统里内核代码)

	eselect kernel list

选择需要的代码

	eselect kernel set 2

/usr/src/linux这个软链接就会指向相应的代码

编译

	genkernel all

更新grub

	grub2-mkconfig -o /boot/grub/grub.cfg

## 如何编写一个gentoo的ebuild

在localoverlay里创建相应的ebuild文件

创建/usr/local/portage/app-misc/hello-world/hello-world-1.0.ebuild文件内容如下

其中SRC_URI这里用的是本地的一个文件

cat hello-world-1.0.ebuild

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

指定我们的源码路径,这里用的是本地的文件

hello-world-1.0.tar.gz里包含的文件如下

	hello-world-1.0/hello.c
	hello-world-1.0/Makefile

cat hello.c

	#include <stdio.h>

	int main(int argc, char **argv)
	{
		printf("hello my first ebuild\n");
		return 0;
	}

cat Makefile

	all:hello.c
		gcc -o hello-world hello.c

把这两个文件打包后放到指定目录即可

	tar czvf hello-world-1.0.tar.gz hello-world-1.0/*

生成相应的Manifest文件

	ebuild /usr/local/portage/app-misc/hello-world/hello-world-1.0.ebuild manifest

测试安装软件

	emerge app-misc/hello-world

执行软件

	hello-world

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

## 安装二进制(BinaryPackage)的软件包

### 主机上操作(BinaryHost)

在主机上生成当前系统里所有已安装软件的binary包

	emerge -uDN @world --buildpkg

生成的所有包都在/usr/portage/packages目录里

设置BinaryHost主机(使用SSH协议)

这里将客户端root用户的公钥添加到主机root用户的authorized文件

	# cat .id_rsa.pub >> /root/.ssh/authorized_keys

### 客户端操作(BinaryClient)

添加下面内容到/etc/portage/make.conf文件(BinaryHost IP 192.168.1.100)

	PORTAGE_BINHOST="ssh://root@192.168.1.100/usr/portage/packages"

安装Binary软件

	emerge -G package_name

## Misc

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

## Install Gentoo from LiveDVD

[Quick Way Install Gentoo](mds/livedvd_install.md)
