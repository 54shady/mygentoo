```shell
1. 系统安装:
mkfs.ext4 /dev/sda7
swapon /dev/sda10
mount /dev/sda7 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda11 /mnt/gentoo/boot
cd /mnt/gentoo
tar xvjpf stage3-*.tar.bz2 --xattrs

make.conf文件配置如下：
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

先使用profile 1
eselect profile set 1

emerge -a sys-kernel/gentoo-sources

emerge --ask sys-kernel/genkernel
genkernel all

nano -w /etc/conf.d/hostname
hostname="mobz"

emerge --noreplace net-misc/netifrc

修改网络配置文件：
/etc/conf.d/net
config_eth0="dhcp"

cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

passwd root

2. 安装KDE桌面环境
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

3. 安装字体和输入法
emerge -av wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts

安装输入法和配置fcitx的工具
emerge -av fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

我使用的是KDE桌面环境所以在~/.xprofile里添加如下内容：
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
eval "$(dbus-launch --sh-syntax --exit-with-session)"

http://blog.sina.com.cn/s/blog_510ac7490100u2wb.html

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
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"

4. 访问google
直接安装miredo就可以了
emerge miredo
之后启动miredo就能看到一张teredo的虚拟网卡
ping6 ipv6.google.com 测试是否可以ping 通


5. 安装ADB 和FASTBOOT
方法1：这个方法没成功
emerge --ask android-sdk-update-manager
由于安装时需要去google的网上下代码，下载太慢导致无法下载成功，所以这里手动下载了需要的代码，我下载的是android-sdk_r23-linux.tgz
下载完后把该文件放到了/usr/portage/distfiles目录下即可
方法2：
直接把ubuntu上的/usr/bin/adb 和 /usr/bin/fastboot拷贝到gentoo的/opt/tools/下
export PATH=$PATH:/opt/tools

把ubuntu上的下面几个动态库拷贝到gentoo里来（按照操作提示即可）：
cp /lib/x86_64-linux-gnu/libselinux.so.1 /usr/lib/
cp /lib/x86_64-linux-gnu/libpcre.so.3.13.1 /usr/lib/
ln -s /usr/lib/libpcre.so.3.13.1 /usr/lib/libpcre.so.3
之后就可以使用adb 和fastboot了

6. kconsole solarized
https://techoverflow.net/blog/2013/11/08/installing-konsole-solarized-theme/

Problem: You’re using the KDE4 Konsole and you want to install the Solarized color scheme plugin. However, you are way too lazy to figure out how to do that manually.

Solution:

Just copy-n-paste this into your favourite shell:

if [ -d ~/.kde4 ]; then
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde4/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
else
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Light.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Light.colorscheme"
	wget -qO ~/.kde/share/apps/konsole/Solarized\ Dark.colorscheme "https://raw.github.com/phiggins/konsole-colors-solarized/master/Solarized%20Dark.colorscheme"
fi

After that, you only have to select the appropriate color profile (Settings —> Edit current profile —> Appearance).


7. Let tmux automatic load the .bashrc file
让tmux自动加载.bashrc文件在.bash_profile文件里添加下面这句话
. ~/.bashrc

8. 使用WIN+D来像WINDOWS一样显示桌面
System Settings > Shortcuts and Gestures > Global Keyboard Shortcuts > KDE component: KWin > Show Desktop
设置成win+d即可

9. virtual box 安装：
在package.accept_keywords添加如下内容来安装最新的virtualbox和相应的增强工具：
>=app-emulation/virtualbox-5.0.14 ~amd64
>=app-emulation/virtualbox-additions-5.0.14 ~amd64

安装虚拟机:
emerge  app-emulation/virtualbox

安装WINDOWS虚拟机相应的增强工具:
emerge app-emulation/virtualbox-additions

因为我用root登入,所以添加root到vboxusers
gpasswd -a root vboxusers

根据gentoo virtualbox wiki,Rebuild the VirtualBox kernel modules with:
emerge -1 @module-rebuild

手动加载虚拟机的驱动：
modprobe vboxdrv

将虚拟机驱动模块加入到系统启动加载模块中：
在/etc/conf.d/modules中添加下面一行
modules="vboxdrv"

10. 添加新用户mobz 默认组为users,附加组为adm,sys
useradd  -m -g users -G adm,sys -s /bin/bash mobz
passwd mobz
```