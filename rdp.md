# 远程桌面(Xvnc, xrdp)

通过windows默认远程连接到linux(gentoo dwm)

linux安装如下软件(Xvnc)

	tigervnc(需要的use : server)
	xrdp (使用zeroway的overlay安装)

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

## 连接一个新会话

windows端mstsc远程连接式会话选择(Xorg,Xvnc)

- 使用Xorg作为Session连接不需要安装tigervnc
- 使用Xvnc作为Session连接时需要安装tigervnc

其中使用Xvnc会话,在主机上可以看到如下

	Xvnc :10 -auth .Xauthority -geometry 1024x768 -depth 32 -rfbauth /home/zeroway/.vnc/sesman_passwd-zeroway@zpc:10 -bs -nolisten tcp -localhost -dpi 96

进入系统后打开终端配置显示设备,sesman.ini中配置的(否则应用会在主机上显示)

	echo $DISPLAY
	:10.0

	export DISPLAY=:10.0

## 连接当前会话

服务端上创建一个密码文件

	vncpasswd current-session-pwd

服务端启动vncserver(客户端可以通过默认5900端口进行vnc连接)

	x0vncserver -passwordfile current-session-pwd

使用端口6666

	x0vncserver rfbport=6666 -passwordfile ~/.grice/current-session-pwd

在客户端上连接服务器

	vncviewer <ip>:5900
