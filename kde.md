# ~~已废弃,不再维护~~

## ~~桌面环境配置(KDE) 不再维护~~

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
