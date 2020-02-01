# i3wm(gentoo openrc)

## 不安装Display Manger启动系统

安装必要的软件包

	emerge xorg-x11 twm xclock xterm dbus

## 在tty1中进入系统后启动startx

使用openrc作为init进程的系统(.bash_profile)

	if shopt -q login_shell; then
		[[ -f ~/.bashrc ]] && source ~/.bashrc
		[[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec startx
	else
		exit 1 # Somehow this is a non-bash or non-login shell.
	fi

## 启动startx参数

启动startx后会执行.xinitrc(脚本中内容是传递给startx的参数)

	exec i3

## i3wm Power Manager

将用户sudo免密码操作(/etc/sudoers)

	username ALL=(ALL) NOPASSWD: ALL

让普通用户能重启系统

	chmod +s /sbin/reboot
	chmod +s /sbin/poweroff

## luvcview

使用luvcview需要权限

	crw-rw----+ 1 root video 81, 0 Oct 19 19:57 /dev/video0

添加到video组即可

	usermod -a -G video your_user_name

## mpd and ncmpcpp configuation

package

	media-sound/mpd (sqlite libmpdclient)
	media-sound/ncmpcpp

mpd : media player server
ncmpcpp : client for mpd

### MPD

mpd config

	mkdir -p ~/.mpd/playlists/

edit the config file[~/.mpd/mpd.conf](mpd.conf)

add user to the audio group

	sudo gpasswd -a audio zeroway

test config

	$ mpd
	$ ss -tunelp | grep 6600
	tcp     LISTEN   0        5              127.0.0.1:6600          0.0.0.0:*
	users:(("mpd",pid=14167,fd=10)) uid:1000 ino:73469 sk:d2 <->

### NCMPCPP

ncmpcpp config

	mkdir -p ~/.ncmpcpp/lyrics

config file for ncmpcpp[~/.ncmpcpp/config](ncmpcpp_config)

startup the ncmpcpp and update the database by press 'u'
