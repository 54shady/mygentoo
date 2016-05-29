```shell
新买笔记本thinkpad E460,预装windows 10支持UEFI启动
/dev/sda1就是EFI分区,gentoo也使用这个分区

使用刻录ubuntu14.04到u盘,这里借用ubuntu的刻录盘来进入到UEFI模式
http://jingyan.baidu.com/article/a378c960630e61b329283045.html

使用UEFI模式启动,需要关掉secure boot功能
分区和挂载点:
sda4 /home
sda5 /
sda6 swap
sda1 是笔记本出厂就
mkfs.ext4 /dev/sda4
mkfs.ext4 /dev/sda5
mkswap /dev/sda6
swapon  /dev/sda6

mkdir /mnt/gentoo
mount /dev/sda5 /mnt/gentoo/
mkdir /mnt/gentoo/boot/efi -p

挂载EFI分区
mount /dev/sda1 /mnt/gentoo/boot/efi

解压stage3
tar xvjpf /cdrom/stage3-amd64-20160526.tar.bz2 --xattrs -C /mnt/gentoo/

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

make.conf文件配置如下：
/mnt/gentoo/etc/portage/make.conf
GENTOO_MIRRORS="http://mirrors.sohu.com/gentoo/ http://mirrors.163.com/gentoo/ "
SYNC="rsync://mirrors.163.com/gentoo-portage"
MAKEOPTS="-j8"

fstab内容,不过发现sda1并没有挂载上来:
/dev/sda4	/home	ext4	noatime	0	3
/dev/sda5	/	ext4	noatime	0	1
/dev/sda6	none	swap	sw	0	0
/dev/sda1	/boot/efi	vfat	noauto,noatime	1	2

cp -L /etc/resolv.conf /mnt/gentoo/etc/

拷贝portage
cp /cdrom/portage-20160520.tar.bz2 /mnt/gentoo/
chroot /mnt/gentoo/ /bin/bash

解压portage
tar jxvf portage-20160520.tar.bz2 -C /usr/

选择profile
eselect profile set 1

编译内核
emerge sys-kernel/gentoo-sources
emerge sys-kernel/genkernel
genkernel all

=======这里是最重要到其他都可以参考之前到安装===========
下面到操作要保证能成功的前提是启动到时候是UEFI模式启动的

安装grub支持EFI,这里指定的EFI目录就是挂载到sda1
echo GRUB_PLATFORMS="efi-64" >> /etc/portage/make.conf
emerge sys-boot/grub:2
grub2-install  --target=x86_64-efi --efi-directory=/boot/efi
grub2-mkconfig -o /boot/grub/grub.cfg
=======这里是最重要到其他都可以参考之前到安装===========

nano -w /etc/conf.d/hostname
hostname="zerowayE460"

修改网络配置文件：
/etc/conf.d/net
config_eth0="dhcp"

cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

passwd root
重启下
reboot

安装KDE桌面环境
eselect profile set 6

添加下面的几个USE
USE＝"...dbus policykit udev udisks"
emerge --changed-use --deep @world
emerge kde-apps/kdebase-meta
emerge xorg-x11
emerge kde-base/kdm

/etc/conf.d/xdm
DISPLAYMANAGER="kdm"
rc-update add xdm default

修改KDE配置文件，让root可以登入
/usr/share/config/kdm/kdmrc
AllowRootlogon = true

安装字体和输入法
emerge -av wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts

安装输入法和配置fcitx的工具
emerge -av fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

我使用的是KDE桌面环境所以在~/.xprofile里添加如下内容：
在每个用户目录下都要有这个才能使用输入法
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
eval "$(dbus-launch --sh-syntax --exit-with-session)"

设置locale:
在/etc/locale.gen中添加:
en_US ISO-8859-1
en_US.UTF-8 UTF-8
zh_CN GB18030
zh_CN.GBK GBK
zh_CN.GB2312 GB2312
zh_CN.UTF-8 UTF-8

保存执行locale-gen
#locale-gen

emerge arphicfonts wqy-bitmapfont  corefonts ttf-bitstream-vera

建立 /etc/env.d/100i18n
在/etc/env.d/100i18n中添加:
LANG=en_US.UTF-8
LC_CTYPE=zh_CN.UTF-8
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_PAPER="en_US.UTF-8" LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"

安装完成后重启添加pinyin输入法

kconsole solarized
在shell下输入下面内容

if [ -d ~/.kde4 ]; then
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
else
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
fi

NetworkManager
删除系统默认的网络管理
rc-update del net.enp5s0
rm /etc/conf.d/net
rm  /etc/init.d/net.enp5s0

安装NetworkManager 和 networkmanagement
emerge net-misc/networkmanager
emerge kde-misc/networkmanagement
之后需要添加相应的widget才可以看到有系统托盘出现
rc-update add NetworkManager  default

安装wifi固件
emerge sys-kernel/linux-firmware


virtual box 安装：
在package.accept_keywords添加如下内容来安装最新的virtualbox和相应的增强工具：
=app-emulation/virtualbox-bin-5.0.20.106931 ~amd64
=app-emulation/virtualbox-modules-5.0.20 ~amd64
=app-emulation/virtualbox-additions-5.0.20 ~amd64

emerge  app-emulation/virtualbox
gpasswd -a zerowaytp vboxusers
emerge -1 @module-rebuild
modprobe vboxdrv

将虚拟机驱动模块加入到系统启动加载模块中：
在/etc/conf.d/modules中添加下面一行
modules="vboxdrv"
```
