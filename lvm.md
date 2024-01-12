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

# LVM usage (Test on ubuntu 22.04 vm)

[lvm locking for data stores](https://docs.onapp.com/agm/6.0/storage-settings/data-stores-settings/logical-volume-management-lvm/lvm-locking-for-data-stores)

## qemu command

	qemu
	-drive file=ubt2204.qcow2,index=1,media=disk
	-drive file=data.qcow2,index=2,media=disk

## install packages

	apt install lvm2 multipath-tools lvm2-lockd sanlock libsanlock1

## Create logical volume

create Physical Volume

	pvcreate /dev/sdb
	pvdisplay

create Volume Group name myvg on /dev/sdb

	vgcreate myvg /dev/sdb
	vgdisplay

create Logical Volume(/dev/mapper/myvg-mylv -> ../dm-0)

	lvcreate -L 10G -n mylv myvg
	lvdisplay

## Using logical volume

format logical volume

	mkfs.ext4 /dev/myvg/mylv

mount logical volume

	mkdir /mnt/
	mount -t /dev/myvg/mylv /mnt

## Delete logical volume

delete Logical Volume

	lvremove /dev/myvg/mylv

delete Volume Group

	vgchange -an myvg
	vgremove myvg

delete physical volume

	pvremove /dev/sdb

## multipath(Test on Physical Machine)

依赖的内核模块

	modprobe dm_multipath

create the logical volume and do pvscan(/dev/mapper/myvg-mylv -> ../dm-0)

	pvscan

	systemctl restart multipathd multipath-tools.service
	systemctl start multipathd.service

查询磁盘信息(执行完pvcreate /dev/sdb后无法看到该磁盘)

	lshw -c disk
	hwinfo --disk

找出磁盘的product和Vendor信息

	product: SAMSUNG MZ7LH480
	Vendor: "SAMSUNG"

将信息填入到/etc/multipath.conf中

	devices {
			device {
			 vendor "SAMSUNG"
			 product "SAMSUNG MZ7LH480"
			 path_grouping_policy group_by_serial
			}
	}

查看multipathd的配置

	multipathd show config
	multipath -t

此时就可以通过命令查看到multipath的拓扑情况

	multipath -l

## using sanlock as [lock manager] for LVM

[man lvmlockd](http://rpm.pbone.net/manpage_idpl_31677851_numer_8_nazwa_lvmlockd.html)

enable lvmlockd and sanlock

	systemctl start lvmlockd
	systemctl start sanlock

enable lvm using lock and setup hostid (/etc/lvm/lvm.conf)

	global {
		...
		use_lvmlockd = 1
		...
	}
	local {
		host_id=11
	}

restart lvmlockd and locks

	systemctl restart lvmlockd lvmlocks

create VG on shared devices

	vgcreate --shared myvg /dev/sdb

start VG lock on all hosts

	vgchange --lock-start

create Logical Volume

	lvcreate -L 10G -n mylv myvg
	lvdisplay

list block device using **lsblk** will see the myvg-lvmlock device

	sdb               8:16   0   100G  0 disk
	├─myvg-lvmlock 253:0    0   256M  0 lvm
	└─myvg-mylv    253:1    0    10G  0 lvm

check the sanlock status using command **sanlock status**

	daemon 965af208-5dab-48aa-8d58-e822dbe481f0.zeroway-Sta
	p -1 helper
	p -1 listener
	p 21399 lvmlockd
	p -1 status
	s lvm_myvg:11:/dev/mapper/myvg-lvmlock:0
	r lvm_myvg:Y0MvQU-VzCz-LUjW-hJol-10ex-pHyx-BcDuup:/dev/mapper/myvg-lvmlock:70254592:1 p 21399

check lvm global lock

	lvmlockctl -i

## why using lvm(enlarge the partition or disk)

### qemu command(sdb和sdc分别都是100G的磁盘)

	qemu
	-drive file=ubt2204.qcow2,index=1,media=disk
	-drive file=data00.qcow2,index=2,media=disk
	-drive file=data01.qcow2,index=3,media=disk

(将两个100G的硬盘合并成一个VG(myvg)并划分一个150G的LV(mylv))

在两个磁盘上创建出PV

	pvcreate /dev/sdb /dev/sdc
	pvscan

创建出一个VG(vg size就是200G)

	vgcreate myvg /dev/sdb /dev/sdc
	vgdisplay

创建出一个150G的LV

	lvcreate -L 150G -n mylv myvg
	lvdisplay

格式化后挂载使用该150G的LV

	mkfs.ext4 /dev/myvg/mylv
	mount /dev/myvg/mylv /mnt/

对LV进行扩容到180G

	umount /mnt
	lvextend -L 180G /dev/myvg/mylv
	e2fsck -f /dev/myvg/mylv
	resize2fs /dev/myvg/mylv
	mount /dev/myvg/mylv /mnt/

## FAQ

1. Logical volume myvg/mylv in use.

	lsof /dev/myvg/mylv

2. pvremove /dev/sdb  提示失败

	Global lock failed: check that global lockspace is started

修改use_lvmlockd = 0

	sed -i 's/use_lvmlockd = 1/use_lvmlockd = 0/' lvm.conf

	pvremove /dev/sdb
	Labels on physical volume "/dev/sdb" successfully wiped.
