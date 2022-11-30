## Linux开发环境搭建

### TFTP服务器搭建

在gentoo上安装tftp软件

  sudo emerge -v net-ftp/atftp

配置文件(/etc/conf.d/atftp)内容如下

	# Config file for tftp server
	TFTPD_ROOT="/home/zeroway/github/matrix"
	TFTPD_OPTS="--daemon --user nobody --group nobody"

开启tftp服务(服务器IP:192.168.1.100)

	/etc/init.d/atftp start

在开发板上使用tftp(比如从tftp服务器上获取libfahw.so)

	tftp -g 192.168.1.100 -r lib/libfahw.so
	cp libfahw.so lib/

拷贝一个测试程序

	tftp -g 192.168.1.100 -r demo/matrix-pwm/matrix-pwm
	chmod +x matrix-pwm
	./matrix-pwm

交互式ftp客户端使用

	lftp -e 'set ssl:verify-certificate false' -u username,password -p 21 192.168.1.100

### NFS服务器[使用docker搭建参考这里](./docker/README.md)

内核配置(gentoo内核配置NFS相关选项参考官网即可)

安装相应的工具

	emerge --ask net-fs/nfs-utils

创建相关的目录

	mkdir /export
	mkdir /export/nfs_rootfs
	mount --bind /home/zeroway/armlinux/rootfs_for_3.4.2 /export/nfs_rootfs

在/etc/exports文件中添加如下内容

	/export/nfs_rootfs *(rw,sync,no_root_squash)

修改了该文件后需要执行

	exportfs -rv

配置/etc/conf.d/nfs这个文件,支持NFS版本在这里设置

	OPTS_RPC_NFSD="8 -V 2 -V 3 -V 4 -V 4.1"

gentoo上先测试是否可以挂载

	/etc/init.d/nfs start

使用VER2

	mount -t nfs -o nolock,vers=2 192.168.1.101:/export/nfs_rootfs /mnt

使用VER4

	mount -t nfs -o nolock,vers=4 192.168.1.101:/export/nfs_rootfs /mnt

在开发板上设置相关的参数

其中:gentoo_pc_ip=192.168.1.101,开发板:192.168.1.230

	set machid 7cf ;set bootargs console=ttySAC0,115200 root=/dev/nfs nfsroot=192.168.1.101:/export/nfs_rootfs ip=192.168.1.230:192.168.1.101:192.168.1.1:255.255.255.0::eth0:off ;nfs 30000000 192.168.1.101:/export/nfs_rootfs/uImage;bootm 30000000

开机启动相关配置

在/etc/fstab中添加下面内容

	/home/zeroway/armlinux/rootfs_for_3.4.2 /export/nfs_rootfs none bind 0 0

添加开机启动

	rc-update add nfs default

### 环境变量设置

全局环境变量配置

在/etc/env.d/添加一个文件,名字随意,自己知道是给什么软件配置的就可以

由于是给arm-linux-gcc 4.3.2版本配置,所以我写成了432arm-linux-gcc

里面写入相关的路径,比如交叉编译工具在/opt/toolschain/usr/local/arm/4.3.2/bin

432arm-linux-gcc文件内容如下

	PATH="/opt/toolschain/usr/local/arm/4.3.2/bin"
	ROOTPATH="/opt/toolschain/usr/local/arm/4.3.2/bin"

之后执行下面的命令就可以更新环境变量了

	env-update && source /etc/profile

局部环境变量配置

在.bashrc里添加或是export配置PATH

### 32位库文件问题

编译android 5.1源代码的时候发现有下面的错误

	out/host/linux-x86/bin/aapt: error while loading shared libraries: libz.so.1: cannot open shared object file: No such file or directory

由于该ARM是32位的,编译到时候要用到32位到库文件

而我用到gentoo linux是64位到系统,系统到默认库是64位的

	ls -l /usr/lib
	lrwxrwxrwx 1 root root 5 May 26 01:19 /usr/lib -> lib64

先找到上面编译错误时需要用的库是属于那个软件包的

	equery b libz.so
	sys-libs/zlib-1.2.8-r1 (/usr/lib64/libz.so)

查看这个软件包编译安装到时候用到use是什么,发现没有支持32位

	equery u sys-libs/zlib
		- - abi_x86_32  : 32-bit (x86) libraries

修改use重新安装即可,在USES里添加

	# need by android 32bit lib
	sys-libs/zlib abi_x86_32

### adb fastboot dnw等本地非root用户工具

在宿主目录下创建一个目录,这里假设是~/Tools

这个目录下放的都是本用户的二进制工具

把adb fastboot dnw dtc mkimage等工具放到这个目录下

因为fastboot dnw这些工具需要sudo 权限才可以执行

在.bashrc里export 这个路径

	export PATH=$PATH:~/Tools

修改/etc/sudoers,添加下面内容

	Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/zeroway/Tools"

上面把/home/zeroway/Tools这个目录添加到sudo搜索工具的目录

### 挂载WINDOWS共享目录

假设WINDOWS(192.168.1.123)共享目录名为WinShare,挂载目录/mnt/test(fstab如下)

	//192.168.1.123/WinShare  /mnt/test  cifs defaults,iocharset=utf8,uid=1000,gid=1000,rw,dir_mode=0777,file_mode=0777,username=AAA,password=BBB

