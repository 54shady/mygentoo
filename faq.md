## FAQ

### 软件安装

安装软件遇到license问题

	!!! The following installed packages are masked:
	- sys-kernel/linux-firmware-99999999::gentoo (masked by: || ( )
	  linux-fw-redistributable no-source-code license(s))
	  A copy of the 'linux-fw-redistributable' license is located at
	  '/usr/portage/licenses/linux-fw-redistributable'.

	  A copy of the 'no-source-code' license is located at
	  '/usr/portage/licenses/no-source-code'.

单独添加对应的license

	echo 'sys-kernel/linux-firmware linux-fw-redistributable no-source-code' >> /etc/portage/package.license

或者在make.conf中添加如下内容

	ACCEPT_LICENSE="linux-fw-redistributable no-source-code"

缺少keyword问题

  !!! All ebuilds that could satisfy "sys-kernel/linux-firmware" have been
  masked.
  !!! One of the following masked packages is required to complete your request:
  - sys-kernel/linux-firmware-99999999::gentoo (masked by: || ( )
    linux-fw-redistributable no-source-code license(s), missing keyword)

在ebuild文件中添加对应的keyword比如下面

	KEYWORDS="~arm64"

### 系统使用

#### 无法挂载根文件系统

替换内核后系统启动时用auto类型挂载磁盘导致卡住

	Using mount -t auto -o ro /dev/sdc2 /newroot

查看genkernel中linuxrc源码,可以在cmdline中配置这个(rootfstype=ext4)

	rootfstype=*)
		ROOTFSTYPE=${x#*=}

	good_msg "Using mount -t ${ROOTFSTYPE} -o ${MOUNT_STATE} ${REAL_ROOT} ${NEW_ROOT}"
	run mount -t ${ROOTFSTYPE} -o ${MOUNT_STATE} ${REAL_ROOT} ${NEW_ROOT}

#### 无法启动X window

错误如下

	parse_vt_settings: Cannot open /dev/tty0 (Permission denied)

问题是由于xorg安装时未配置当前用户权限,尝试重新安装xorg解决,如果无法解决手动修改

	chmod +s /usr/bin/Xorg

#### Address already in use(端口被占用)

查看是哪个程序占用,发现时Xorg,直接杀掉相应的进程

	$ sudo netstat -plunt
	Active Internet connections (only servers)
	Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
	tcp        0      0 0.0.0.0:5900            0.0.0.0:*               LISTEN      6412/Xorg
	...

	$ top -p 6412 -H
	top - 17:02:53 up 2 days, 3 min,  1 user,  load average: 0.22, 0.31, 0.48
	Threads:   3 total,   0 running,   3 sleeping,   0 stopped,   0 zombie
	%Cpu(s):  1.1 us,  2.2 sy,  0.0 ni, 96.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
	GiB Mem :      7.6 total,      0.8 free,      3.1 used,      3.8 buff/cache
	GiB Swap:      8.0 total,      6.9 free,      1.1 used.      3.9 avail Mem

	  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
	 6412 root      20   0  595984  25500  12156 S   0.0   0.3   0:00.08 Xorg
	 6413 root      20   0  595984  25500  12156 S   0.0   0.3   0:00.00 SPICE Worker
	 6417 root      20   0  595984  25500  12156 S   0.0   0.3   0:00.00 InputThread

#### process status in 'D' status

某应用程的运行状态是D状态时,通过top可查看到

	D = uninterruptible sleep 不可打断的睡眠状态

查看系统中所有处在D状态的进程的调用栈

	echo w > /proc/sysrq-trigger && dmesg

查看该指定程序的调用栈情况

	cat /proc/<pid>/stack

#### 高版本openssh导致问题

Unable to negotiate with XX.XXX.XX.XX: no matching host key type found.
Their offer: ssh-dss no matching host key type found. Their offer: ssh-rsa,ssh-dss

需要在~/.ssh/config添加如下内容(使用rsa算法支持)

	Host *
	HostKeyAlgorithms +ssh-rsa
	PubkeyAcceptedKeyTypes +ssh-rsa

#### ping (connect：network is unreachable)

问题是由于缺少下面这条默认路由导致

假设需要通过wlan0上网

	wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			inet 192.168.19.99  netmask 255.255.255.0  broadcast 192.168.19.255

关于route带参数-n输出(-n don't resolve names)

	route -n
	Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
	0.0.0.0         192.168.19.1    0.0.0.0         UG    0      0        0 wlan0

不带参数route的输出如下

	Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
	default         bogon           0.0.0.0         UG    0      0        0 wlan0

可以看到0.0.0.0被解析成default, 默认.1的网关被解析成bogon

如果route查看路由只有下面这一条的话,可定是无法连网的

	Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
	192.168.19.0    0.0.0.0         255.255.255.0   U     0      0        0 wlan0

ping 8.8.8.8  会有如下错误

	connect：network is unreachable

需要添加一条默认路由

	route add default gw 192.168.19.1

#### 挂载ntfs分区的盘变成只读

	mount /dev/nvme0n1p3 /data/p3/

	The disk contains an unclean file system (0, 0).
	Metadata kept in Windows cache, refused to mount.
	Falling back to read-only mount because the NTFS partition is in an
	unsafe state. Please resume and shutdown Windows fully (no hibernation
	or fast restarting.)
	Could not mount read-write, trying read-only

需要如下修复

	apt-get install ntfs-3g
	ntfsfix  /dev/nvme0n1p3
