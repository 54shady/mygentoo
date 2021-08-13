# Mount LVM Disk

## 执行下面的mount时遇到问题如下

mount /dev/sda3 /mnt

	unknown filesystem type 'LVM2_member'.

是用lsblk查看结果如下

	NAME          MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
	sda             8:0    0 447.1G  0 disk
	├─sda1          8:1    0     1M  0 part
	├─sda2          8:2    0     1G  0 part
	├─sda3          8:3    0 445.6G  0 part
	│ ├─yourVGname-data 253:0    0    98G  0 lvm
	│ └─yourVGname-root 253:1    0    50G  0 lvm
	└─sda4          8:4    0   512M  0 part

## 环境准备

需要安装lvm工具(sys-fs/lvm2)

安装完后启动相应程序

	/etc/init.d/lvmetad start

## 检查相关信息

lvscan扫描得到如下结果,发现是为激活状态

	inactive          '/dev/yourVGname/data' [98.00 GiB] inherit
	inactive          '/dev/yourVGname/root' [50.00 GiB] inherit

vgdisplay的结果如下

	--- Volume group ---
	VG Name               yourVGname
	System ID
	Format                lvm2
	Metadata Areas        1
	Metadata Sequence No  5
	VG Access             read/write
	VG Status             resizable
	MAX LV                0
	Cur LV                2
	Open LV               0
	Max PV                0
	Cur PV                1
	Act PV                1
	VG Size               <445.57 GiB
	PE Size               4.00 MiB
	Total PE              114065
	Alloc PE / Size       37888 / 148.00 GiB
	Free  PE / Size       76177 / <297.57 GiB
	VG UUID               48nUdQ-M37q-SV3X-eDZl-DEFO-eeZF-WaFZbB

## 修改

激活对应的磁盘

	vgchange -ay yourVGname
	2 logical volume(s) in volume group "yourVGname" now active

查看对应目录下的文件(ls /dev/mapper)

	control  yourVGname-data  yourVGname-root

此时用lvscan可以看到已经激活

	ACTIVE            '/dev/yourVGname/data' [98.00 GiB] inherit
	ACTIVE            '/dev/yourVGname/root' [50.00 GiB] inherit

## 挂载

挂载对应的文件即可

	mount /dev/yourVGname/data /mnt/
