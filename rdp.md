### 远程桌面(Xvnc, xrdp)

通过windows默认远程连接到linux(gentoo dwm)

linux安装如下软件(Xvnc)

	tigervnc (需要的use : server)
	xrdp (使用ace的overlay安装)

启动Xvnc和xrdp

	/etc/init.d/xrdp start

配置开机启动

	rc-update add xrdp default

文件/etc/xrdp/sesman.ini中配置了Xvnc的默认配置

	UserWindowManager=startwm.sh
	DefaultWindowManager=startwm.sh
	ReconnectScript=reconnectwm.sh
	X11DisplayOffset=10

其中使用startwm.sh来配置远程桌面的显示

	USERINITRC="$HOME/.xinitrc"
	if [ -f "$USERINITRC" ]; then
		. "$USERINITRC"
	else
		. /etc/X11/xinit/xinitrc
	fi

一个简单的.xinitrc内容如下

	# load the X resources before WM
	[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

	# Make sure this is before the 'exec' command or it won't be sourced.
	[ -f /etc/xprofile ] && . /etc/xprofile
	[ -f ~/.xprofile ] && . ~/.xprofile

	exec dwm

所以如果宿主目录下有.xinitrc文件的话就用该文件

~~宿主目录下VNC配置文件(~/.vnc/xstartup)~~

	#!/bin/sh

	unset SESSION_MANAGER
	unset DBUS_SESSION_BUS_ADDRESS
	exec /home/zeroway/.remote_xinitrc

~~其中[.remote_xinitrc文件](./remote_xinitrc)参考这里~~

windows端mstsc远程连接使用Xvnc作为Session

进入系统后打开终端配置显示设备,sesman.ini中配置的(否则应用会在主机上显示)

	echo $DISPLAY
	:10.0

	export DISPLAY=:10.0
