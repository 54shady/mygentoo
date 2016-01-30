```shell
mkfs.ext4 /dev/sda7
swapon /dev/sda10
mount /dev/sda7 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda11 /mnt/gentoo/boot
cd /mnt/gentoo
tar xvjpf stage3-*.tar.bz2 --xattrs

/mnt/gentoo/etc/portage/make.conf
GENTOO_MIRRORS="http://mirrors.sohu.com/gentoo/ http://mirrors.163.com/gentoo/ "
SYNC="rsync://mirrors.163.com/gentoo-portage"
MAKEOPTS="-j8" 
FEATURES = "ccache"
CCACHE_SIZE="3G" 
CCACHE_DIR="/var/tmp/ccache"
FETCHCOMMAND="/usr/bin/axel -a -o \${DISTDIR}/\${FILE} \${URI}"
RESUMECOMMAND="${FETCHCOMMAND}"

fstab内容:
/dev/sda11   /boot        ext4    defaults,noatime     0 2
/dev/sda10   none         swap    sw                   0 0
/dev/sda7   /            ext4    noatime              0 1

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

emerge --sync

eselect profile set 1

emerge -a sys-kernel/gentoo-sources

emerge --ask sys-kernel/genkernel
genkernel all
nano -w /etc/conf.d/hostname
hostname="mobz"
emerge --noreplace net-misc/netifrc
/etc/conf.d/net
config_eth0="dhcp"
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default
passwd root

安装KDE桌面环境
eselect profile set 6
USE＝"...dbus policykit udev udisks"
emerge --changed-use --deep @world
emerge kde-apps/kdebase-meta
emerge xorg-x11
emerge kde-base/kdm

/etc/conf.d/xdm
DISPLAYMANAGER="kdm"
rc-update add xdm default

/usr/share/config/kdm/kdmrc
AllowRootlogon = true



# 安装字体
emerge -av wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts

# 安装输入法和配置fcitx
emerge -av fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

# 使用 startx 或 slim 的用户，向 ~/.xinitrc 添加以下内容。
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
fcitx &


http://blog.sina.com.cn/s/blog_510ac7490100u2wb.html
 
 2. 设置locale
 2.1 设置 locale.gen
 #gedit /etc/locale.gen
 en_US ISO-8859-1
 en_US.UTF-8 UTF-8
 zh_CN GB18030
 zh_CN.GBK GBK
 zh_CN.GB2312 GB2312
 zh_CN.UTF-8 UTF-8


 保存执行locale-gen
 #locale-gen


 emerge arphicfonts wqy-bitmapfont  corefonts ttf-bitstream-vera

 2.2 建立 /etc/env.d/100i18n
 #gedit /etc/env.d/100i18n

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

 3. 安装SCIM
 #emerge scim scim-pinyin
 如果你需要除拼音外的其他输入法如五笔、二笔、自然码还需安装 scim-tables
 完成后执行
 #scim -d
 ```
