```shell
1. umount busy
我把/dev/sda8 挂在到了/mnt
卸载的时候发现设备忙
用fuser查看是什么在使用导致无法正常卸载

#umount /dev/sda8
umount: /mnt: target is busy
(In some cases useful info about processes that use the device is found by lsof(8) or fuser(1).)

#fuser -u -a -i -m -v /mnt
USER        PID ACCESS COMMAND
/mnt:                root     kernel mount (root)/mnt
		     root       5618 ..c.. (root)adb
发现是adb导致的
查看adb程序确实在运行
ps aux | grep adb
root      5618  0.0  0.0 170360  3168 ?        Sl   Jan30   0:39 adb -P 5037 fork-server server
root     21244  0.0  0.0  15824  2504 pts/3    S+   14:40   0:00 grep --colour=auto adb

停止ADB程序之后就可以正常卸载了
#adb kill-server

2. gcc-config: Active gcc profile is invalid
错误描述
Gentoo软件安装错误,提示：
gcc-config: Active gcc profile is invalid
解决方法：

列出可用的profile
gcc-config -l
gcc-config: Active gcc profile is invalid!
[1] x86_64-pc-linux-gnu-4.9.3

显示当前使用的profile
gcc-config -c
gcc-config: Active gcc profile is invalid!
[1] x86_64-pc-linux-gnu-4.9.3

设置profile
gcc-config x86_64-pc-linux-gnu-4.9.3

3. gentoo samba 安装
emerge -v net-fs/samba
拷贝一个配置文件,在此基础上修改
cp /etc/samba/smb.conf.default /etc/samba/smb.conf

在最后添加下面内容
[myshare]
comment = mobz's share on gentoo
path = /mnt/ubuntu/home/mobz/myandroid
valid users = root mobz
browseable = yes
guest ok = yes
public = yes
writable = no
printable = no
create mask = 0765

修改共享文件的权限
chmod 777 /mnt/ubuntu

添加用户并设置密码
smbpasswd -a root

开启服务
/etc/init.d/samba start

4. GRUB2添加WINDOWS启动

在/etc/grub.d/40_custom里添加下面内容
menuentry "Widnwos 8" {
	insmod ntfs
	set root=(hd0,1)
	chainloader +1
	boot
}

5. konsole添加monaco字体
 把MONACO.TTF字体文件放到/usr/share/fonts/下
 创建一个konsole的配置文件即可:
 ~/.kde4/share/apps/konsole/MonacoFont.profile
 内容如下:
 [Appearance]
 ColorScheme=Solarized
 Font=Monaco,18,-1,5,50,0,0,0,0,0

 [General]
 Name=MonacoFont
 Parent=FALLBACK/
 ShowTerminalSizeHint=false

 [Scrolling]
 ScrollBarPosition=2

 关掉所有konsole后重启就可以了

 6. 普通用户可读root用户挂在的磁盘
 root用户挂在windows盘
 mount -t ntfs -o umask=000 /dev/sda1 /mnt/
 其中/dev/sda1是安装在windows下的ntfs格式的C盘,之后普通用户就可读

 7. gentoo对linux目录结构的解释:

 /bin: Boot-critical applications关键启动程序
 /etc: System administrator controlled configuration files系统配置文件
 /lib: Boot-critical libraries关键启动库
 /opt: Binary-only applications.安装的纯二进制程序
 /sbin: System administrator boot-critical applications系统关键启动程序
 /tmp: Temporary data临时数据
 /usr: General applications普通程序
 /usr/bin: Applications普通应用
 /usr/lib: Libraries普通库
 /usr/local: Non-portage applications. Ebuilds must not install here.使用非portage安装的二进制程序
 /usr/sbin: Non-system-critical system administrator applications非系统关键程序
 /usr/share: Architecture independent application data and documentation架构相关的数据和文档
 /var: Program generated data程序运行是产生的数据
 /var/cache: Long term data which can be regenerated
 /var/lib: General application generated data
 /var/log: Log files

 Where possible, we prefer to put non-boot-critical applications in /usr rather than /. If a program is not needed in the boot process until after filesystems are mounted then it generally does not belong on /.
 在文件系统挂在后才用到的程序应该放在/usr下而不是/下

 Any binary which links against a library under /usr must itself go into /usr (or possibly /opt).

 The /opt top-level should only be used for binary-only applications. Binary-only applications must not be installed outside of /opt.
 单纯的二进制程序只能放到/opt下

 The /usr/local hierarchy is for non-portage software. Ebuilds must not attempt to put anything in here.
 /usr/local里的程序是使用非portage安装的软件,比如手动下载源码包后,手动配置和编译安装

 The /usr/share directory is for architecture independent application data which is not modified at runtime.

 Try to avoid installing unnecessary things into /etc — every file in there is additional work for the system administrator. In particular, non-text files and files that are not intended for system administrator usage should be moved to /usr/share. 
 /etc下只能有文本形式的系统配置文件,非系统配置文件需要放到/usr/share下

8.软件版本后缀意思:
 Suffix 	Meaning

 _alpha 	Alpha release (earliest)
 _beta 	Beta release
 _pre 	Pre release
 _rc 	Release candidate
 (no suffix) 	Normal release
 _p 	Patch release

 9. 使用USB摄像头
	安装了cheese后插入USB摄像头发现如下错误
	(cheese:26600): cheese-WARNING **: Device '/dev/video0' cannot capture at 640x480: /var/tmp/portage/media-plugins/gst-plugins-v4l2-1.4.5/work/gst-plugins-good-1.4.5/sys/v4l2/gstv4l2object.c(2845): gst_v4l2_object_set_format (): /GstCameraBin:camerabin/GstWrapperCameraBinSrc:camera_source/GstBin:bin35/GstV4l2Src:video_source:
	Call to S_FMT failed for YU12 @ 640x480: Input/output error
	提示说无法支持640x480,我这里用的摄像头是OV7740最大分辨率能够达到640x480

	dmesg发现打开摄像头的时候恢报下面的错误:
	uvcvideo: Failed to query (130) UVC probe control : -32 (exp. 26).

	解决办法,修改UVC驱动的参数后发现可以正常使用:
	echo 2 > /sys/modules/uvcvideo/parameters/quirks

	参考:https://www.mail-archive.com/linux-uvc-devel@lists.berlios.de/msg03737.html
```
