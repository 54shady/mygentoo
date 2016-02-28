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

网上一个KDE桌面参考:
https://fitzcarraldoblog.wordpress.com/2012/07/10/a-guided-tour-of-my-kde-4-8-4-desktop-part-1/

3. 安装字体和输入法
emerge -av wqy-zenhei wqy-microhei wqy-bitmapfont wqy-unibit arphicfonts

安装输入法和配置fcitx的工具
emerge -av fcitx fcitx-sunpinyin fcitx-libpinyin fcitx-cloudpinyin fcitx-configtool

我使用的是KDE桌面环境所以在~/.xprofile里添加如下内容：
在每个用户目录下都要有这个才能使用输入法
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

安装完成后重启添加pinyin输入法

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

8.  WIN键的设置
8.1 使用WIN+D来像WINDOWS一样显示桌面
System Settings > Shortcuts and Gestures > Global Keyboard Shortcuts > KDE component: KWin > Show Desktop
设置成win+d即可

8.2 WIN+e 绑定dolphin程序
CustomShortcuts里设置即可

8.3 下面这个设置so nice :)
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

安装sudo
emerge sudo
在/etc/sudoers中添加一行设置相应的用户比如
mobz ALL=(ALL) ALL

11. 开机警告：Warning: Cannot open ConsoleKit session: Unable to open session: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory.
添加dbus 和 consolekit 默认启动
rc-update add dbus default
rc-update add consolekit default

12. sudo的时候能自动补全
emerge bash-completion
echo "complete -cf sudo" >> /home/mobz/.bashrc

13. 安装wicd //图标太丑陋不安装这个,安装后面的kde networkmanagement
emerge wicd
rc-update add wicd default
rc-update del net.enp5s0 我的网卡不是eth0是enp5s
添加下面的内容到/etc/rc.conf里
rc_hotplug="!net.*"

14. NetworkManager
删除系统默认的网络管理
rc-update del net.enp5s0
rm /etc/conf.d/net
rm  /etc/init.d/net.enp5s0

安装NetworkManager 和 networkmanagement
emerge net-misc/networkmanager
emerge kde-misc/networkmanagement  //这个使用的是local overlay装的
之后需要添加相应的widget才可以看到有系统托盘出现
rc-update add NetworkManager  default

15. 实用的widgets,比如rssnow等
emerge kde-base/kdeplasma-addons

rssnow安装后字体显示不方便阅读,可以修改字体显示
System Settings->Application Appearance->Fonts->Small 修改合适的字体大小即可

让rssnow用安装好的火狐浏览器查看网页,设置火狐为默认的浏览器
System Settings->Default Applications->Web Browser:设置为火狐浏览器的位置比如/usr/bin/firefox-bin即可

16. 删除桌面右上角的tool box
先把/usr/share/kde4/services里下面这三个文件备份下
plasma-toolbox-desktoptoolbox.desktop
plasma-toolbox-paneltoolbox.desktop
plasma-toolbox-nettoolbox.desktop
删除该目录下的这三个文件重新登入下就可以了
只想删除右上角的话只要删除plasma-toolbox-desktoptoolbox.desktop这个文件就可以了

17. 安装cairo-dock
去overlay网站上下载ebuild文件,使用localoverlay的方法安装
http://gpo.zugaina.org/x11-misc/cairo-dock
下载的是第一个cairo-dock-9999-r1 ebuild文件
添加新的launcher用的图标都是/usr/share/icons/hicolor/32x32/apps/下的图标
发现安装后有黑边框,估计是集成显卡的原因

18. 安装声卡驱动相关
首先查看声卡驱动
lspci | grep -i audio
在内核中添加相关的驱动支持
确认下面这几个包都安装了
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

19. linux访问windows共享文件夹
先看下共享权限和目录
-L指定共享服务器地址
-U指定共享用户名
smbclient -L //10.1.4.201 -U linwei

将某个目录挂在到本地
mount.cifs -o user=linwei,password=lgw37h97 //10.1.4.201/HR /mnt/win7/
mount.cifs -o user=linwei,password=lgw37h97 //10.1.4.201/id /mnt/win7/

20. 在system tray显示国旗
在System settings里Input Device->keyboard->layout里勾选Show flag
在panel上的system tray右键选择system tray setting后勾选keyboard layout即可显示国旗

21. kazam安装
发现在overlay网站下载sabayon的kazam ebuild文件用localoverlay安装无法成功
原因是无法下载到相应的补丁包
必须要要用layman添加sabayon的overlay来安装才可以
步骤如下:
先安装layman如果安装里就不需要
emerge layman
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf

添加sabayon的overlay
layman -a sabayon

安装kazam
emerge -av media-video/kazam

22. 安装plank
用的是sabayon overlay里的plank
emerge x11-misc/plank
其中火狐会无法pin到plank上
在宿主目录下手动添加下面文件
/home/zeroway/.config/plank/dock1/launchers
内容如下:
[PlankItemsDockItemPreferences]
Launcher=file:///usr/share/applications/firefox-bin.desktop

23. 安装suspend
发现用默认的gentoo portage安装会有冲突
所以就用localoverlay的方法安装
使用的Overlay: bircoph (layman)
emerge sys-power/suspend

卸载upower
emerge --unmerge sys-power/upower

安装pm utils
emerge sys-power/upower-pm-utils

ctrl+alt+F7可以切换到图形登入界面
```
