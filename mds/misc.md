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
```
