### 安装suspend

发现用默认的gentoo portage安装会有冲突

所以就用localoverlay的方法安装

使用的Overlay: bircoph (layman)

	# layman -a bircoph
	# emerge sys-power/suspend

卸载upower

	emerge --unmerge sys-power/upower

安装pm utils

	emerge sys-power/upower-pm-utils

ctrl+alt+F7可以切换到图形登入界面

Suspend to disk with sys-power/pm-utils

配置SWAPFILE

用swapon -s 查看swap分区,假设是/dev/sda8

在/etc/default/grub文件里添加下面内容

	GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/sda8"

重新生成grub配置文件

	grub-mkconfig -o /boot/grub/grub.cfg

更新initramfs

	genkernel --install initramfs

在/etc/pm/config.d/gentoo中添加下面的内容

	SLEEP_MODULE="kernel"

重启系统

	reboot

使用pm utils的工具测试,就可以suspend to disk

	pm-hibernate

也就是点击Hibernate的效果

会把当前电脑所有状态保存在SWAP分区中,之后待机

出发键盘任意键可以唤醒系统,唤醒过程和正常开机一样,只是进入系统后会回复到保存的地方
