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
