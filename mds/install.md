# 分区

```shell
/dev/sda4 ==> swap分区
/dev/sda5 ==> /boot
/dev/sda7 ==> / 
/dev/sda8 ==> /home

mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda7
mkfs.ext4 /dev/sda8
```

# 挂载相应分区,解包stage3

```shell
mount /dev/sda7 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda5 /mnt/gentoo/boot

cd /mnt/gentoo
tar xvjpf stage3-*.tar.bz2 --xattrs
```

# make.conf
make.conf文件配置如下：
/mnt/gentoo/etc/portage/make.conf

```shell
CFLAGS="-O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"
USE="bindist mmx sse sse2 dbus policykit udev udisks icu"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
GENTOO_MIRRORS="http://mirrors.sohu.com/gentoo/ http://mirrors.163.com/gentoo/"
MAKEOPTS="-j8"
```

# fstab
/etc/fstab内容:
```shell
/dev/sda5       /boot   ext4    defaults,noatime        0       2
/dev/sda6       none    swap    sw      0       0
/dev/sda7       /       ext4    noatime 0       1
/dev/sda8       /home   ext4    noatime 0       3
```

```shell
cp -L /etc/resolv.conf /mnt/gentoo/etc/
```

# 挂载必要目录

```shell
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
source /etc/profile
```

# 安装portage

先下载好portage的snapshot压缩包直接解压到/usr/

先使用profile 1

eselect profile set 1

[1]   default/linux/amd64/13.0


# 下载编译内核代码
```shell
emerge -v sys-kernel/gentoo-sources
emerge -v sys-kernel/genkernel
genkernel all
```

# 安装grub
```shell
emerge sys-boot/grub
grub2-install /dev/sda --target=i386-pc
grub2-mkconfig -o /boot/grub/grub.cfg
```

# 配置主机名
```shell
nano -w /etc/conf.d/hostname
hostname="zeroway"
```

# 配置网络文件
```shell
/etc/conf.d/net
config_eth0="dhcp"

cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default
```

# 修改root密码
passwd root

# 安装KDE桌面环境
eselect profile set 6

添加下面的几个USE

```shell
USE＝"...dbus policykit udev udisks"
emerge --changed-use --deep @world
emerge kde-apps/kdebase-meta
emerge xorg-x11
emerge kde-base/kdm

/etc/conf.d/xdm
DISPLAYMANAGER="kdm"
rc-update add xdm default
```

## 修改KDE配置文件，让root可以登入

/usr/share/config/kdm/kdmrc

AllowRootlogon = true

# kconsole solarized
https://techoverflow.net/blog/2013/11/08/installing-konsole-solarized-theme/

Problem: You’re using the KDE4 Konsole and you want to install the Solarized color scheme plugin. However, you are way too lazy to figure out how to do that manually.

Solution:

Just copy-n-paste this into your favourite shell:

```shell
if [ -d ~/.kde4 ]; then
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
else
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
fi
```

After that, you only have to select the appropriate color profile (Settings —> Edit current profile —> Appearance).

# Let tmux automatic load the .bashrc file

让tmux自动加载.bashrc文件在.bash_profile文件里添加下面这句话

. ~/.bashrc

# 添加新用户zeroway 默认组为users,附加组为adm,sys

useradd  -m -g users -G adm,sys -s /bin/bash zeroway

passwd zeroway

# 安装sudo
emerge sudo

在/etc/sudoers中添加一行设置相应的用户比如

zeroway ALL=(ALL) ALL

# virtual box 安装
### 添加下面内容到/etc/portage/package.accept_keywords
```shell
=app-emulation/virtualbox-bin-5.0.20.106931 ~amd64
=app-emulation/virtualbox-modules-5.0.20 ~amd64
=app-emulation/virtualbox-additions-5.0.20 ~amd64

emerge  app-emulation/virtualbox
gpasswd -a zerowaytp vboxusers
emerge -1 @module-rebuild
modprobe vboxdrv
```

## 将虚拟机驱动模块加入到系统启动加载模块中
### 在/etc/conf.d/modules中添加下面一行
modules="vboxdrv"

# 添加dbus 和 consolekit 默认启动

### 解决开机警告：Warning: Cannot open ConsoleKit session: Unable to open session: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory.

rc-update add dbus default

rc-update add consolekit default

# sudo的时候能自动补全

emerge bash-completion

echo "complete -cf sudo" >> /home/mobz/.bashrc

# NetworkManager(删除系统默认的网络管理)
```shell
rc-update del net.enp5s0
rm /etc/conf.d/net
rm  /etc/init.d/net.enp5s0
```

### 安装NetworkManager 和 networkmanagement

emerge net-misc/networkmanager

emerge kde-misc/networkmanagement

之后需要添加相应的widget才可以看到有系统托盘出现

rc-update add NetworkManager  default

# 安装字体和输入法
emerge -av wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts

# 安装输入法和配置fcitx的工具
emerge -av fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

我使用的是KDE桌面环境所以在~/.xprofile里添加如下内容：
在每个用户目录下都要有这个才能使用输入法

```shell
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
eval "$(dbus-launch --sh-syntax --exit-with-session)"
```

# 设置locale:
在/etc/locale.gen中添加:
```shell
en_US ISO-8859-1
en_US.UTF-8 UTF-8
zh_CN GB18030
zh_CN.GBK GBK
zh_CN.GB2312 GB2312
zh_CN.UTF-8 UTF-8
```

# 保存执行locale-gen
locale-gen

# 安装字体
emerge arphicfonts wqy-bitmapfont  corefonts ttf-bitstream-vera

在/etc/env.d/100i18n中添加如下内容
```shell
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
```
安装完成后重启添加pinyin输入法
