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

# 安装到这里最好重启系统后再安装后面的桌面环境

## git server安装到这里就可以了

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

# 使用gentoo搭建git server

# 分区

### 只分了/boot / swap三个分区 (/etc/fstab内容如下)
```shell
/dev/sda2       /boot   ext4    defaults,noatime        0       2
/dev/sda3       none    swap    sw      0       0
/dev/sda4       /       ext4    noatime 0       1
```
### 基本安装过程和上面一样,只不过没有安装图形界面

## git server 搭建

### 静态IP地址配置 (/etc/conf.d/net)
```shell
config_enp1s0="192.168.7.100 netmask 255.255.255.0"
routes_enp1s0="default via 192.168.7.1"
dns_servers_enp1s0="192.168.7.1 8.8.8.8"
```

### 安装git
emerge dev-vcs/git

### 添加git用户

groupadd git

useradd -m -g git -d /var/git -s /bin/bash git

### 编辑/etc/conf.d/git-daemon内容如下

GIT_USER="git"

GIT_GROUP="git"

### 启动相应服务

/etc/init.d/git-daemon start

### 添加开机启动

rc-update add git-daemon  default

### SSH keys 添加到下面文件

在客户端执行ssh-keygen -t rsa

将客户端生成的id_rsa.pub里的内容拷贝到服务器上下面的文件里

/var/git/.ssh/authorized_keys

### 服务器上创建仓库(在服务器上操作,ip:192.168.7.100)

```shell
root # su git
server $cd /var/git
server $mkdir /var/git/newproject.git
server $cd /var/git/newproject.git
server $git init --bare 
```

### 在客户端上把要添加文件到刚才创建的仓库
```shell
client $mkdir ~/newproject
client $cd ~/newproject
client $git init
client $touch test
client $git add test
client $git config --global user.email "M_O_Bz@163.com"
client $git config --global user.name "zeroway"
client $git commit -m 'initial commit'
client $git remote add origin git@192.168.7.100:/var/git/newproject.git
client $git push origin master 
```

### 在其他客户端克隆该仓库

client $git clone git@192.168.7.100:/newproject.git

# 其它
[Happy days in HS](https://github.com/54shady/hs/blob/master/x.md).

# Samba

sudo emerge -v net-fs/samba

拷贝一个配置文件,在此基础上修改

sudo cp /etc/samba/smb.conf.default /etc/samba/smb.conf

添加用户并设置密码

sudo smbpasswd -a zeroway

开启服务

sudo /etc/init.d/samba start

## 设置某个目录为共享目录

在/etc/samba/smb.conf最后添加下面内容

```shell
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
```
