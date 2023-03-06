# [About iSCSI Storage](https://docs.oracle.com/cd/E37670_01/E41138/html/ch17s07s01.html)

- 客户端(使用存储): initiator,可以是在内核或是用户态(qemu)
- 服务端(提供存储): target

假设客户端和服务端不在同一台服务器上

- target在服务器A, ip: 192.168.1.100, 下面用targetip代替
- initiator在服务器B

## 服务端A配置target

安装target程序

	emerge sys-block/tgt

假设target服务器上有两块可用做存储的硬盘sdc,sdd(配置/etc/tgt/targets.conf)

	<target iqn.2012-01.com.mydom.host01:target1>
		direct-store /dev/sdc # LUN 1
		direct-store /dev/sdd # LUN 2
	</target>

启动target服务

	rc-service tgtd start

查看target存储情况

	tgt-admin -s
	tgtadm -o show -m target

## 客户端B配置initiator

安装对应的软件

	emerge sys-block/open-iscsi

启动iscsid

	rc-service iscsid start

搜索target,下面命令都是在root用户下操作

	iscsiadm -m discovery --type sendtargets -p targetip
	iscsiadm -m discoverydb -t st -p targetip

和target建立连接并登入

	iscsiadm -m node T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -l

确认连接是否生效,其中能看到lun的值,在虚拟机参数中用到

	iscsiadm -m session -P 3

	scsi4 Channel 00 Id 0 Lun: 0
	scsi4 Channel 00 Id 0 Lun: 1
			Attached scsi disk sdb          State: running
	scsi4 Channel 00 Id 0 Lun: 2
			Attached scsi disk sdc          State: running

生效后target端的存储(sdc,sdd)就会被映射到本地,本地看到假设为/dev/sdb,/dev/sdc

	ls -l /dev/disk/by-path/
	lsscsi -v

登出target

	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 --logout

### 1. initiator在客户端内核中,以块设备的方式提供存储

将这两块盘(以块设备的方式)给虚拟机使用

	-device virtio-scsi-pci,id=scsi
	-device scsi-hd,drive=sdb -drive if=none,id=sdb,file=/dev/sdb,cache=writeback,format=raw
	-device scsi-hd,drive=sdc -drive if=none,id=sdc,file=/dev/sdc,cache=writeback,format=raw

同步target端信息

	iscsiadm -m discoverydb -t st -p targetip -o new --discover
	iscsiadm -m discoverydb -t st -p targetip -o update --discover
	iscsiadm -m discoverydb -t st -p targetip -o delete --discover

### 2. initiator在客户端内核中,以vhost方式提供存储

在服务器B上安装targetcli软件

	sys-block/targetcli-fb

通过[targetcli](http://linux-iscsi.org/wiki/Targetcli)来创建backstore

创建pscsi的backstore(对/dev/sdc的操作相同)

	cd /backstores/pscsi
	create name=disk1 dev=/dev/sdb

创建vhost节点(用来和/dev/sdb绑定)

	cd /vhost
	/vhost> create
	Created target naa.50014057f9f2abfa

将上面创建的vhost节点和backstore绑定

	cd naa.50014057f9f2abfa/tpg1/luns
	create /backstores/pscsi/disk1

删除backstore

	cd /backstores/pscsi/
	delete disk1

删除vhost节点

	cd /vhost
	delete naa.50014057f9f2abfa

给虚拟机使用wwpn就是上面创建的vhost

	-device vhost-scsi-pci,wwpn=naa.50014057f9f2abfa"

### 3. initiator在qemu中

编译qemu支持用户态的iscsi(--enable-libiscsi)

虚拟机使用(这里的lun的值就是上面查询到的)

	-device virtio-scsi-pci,id=scsi
	-drive if=none,format=iscsi,transport=tcp,portal=targetip:3260,target=iqn.2012-01.com.mydom.host01:target1,id=diska,lun=1
	-device scsi-hd,drive=diska

### 4. multipath(TODO)

修改服务器A(target端)的配置(/etc/tgt/targets.conf)如下

	<target iqn.2012-01.com.mydom.host01:target1>
		direct-store /dev/sdc # LUN 1
	</target>
	<target iqn.2012-01.com.mydom.host01:target2>
		direct-store /dev/sdd # LUN 2
	</target>

在initiator端(服务器B)上查询target情况能发现有连个target

	iscsiadm -m discovery --type sendtargets -p targetip

initiator端安装软件multipath软件

	emerge sys-fs/multipath-tools

先确保退出之前的登录

	iscsiadm -m session -P 3 # 查询是否还有会话
	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 --logout

重新登录

	iscsiadm -m node T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -l
	iscsiadm -m node T iqn.2012-01.com.mydom.host01:target2 -p targetip:3260 -l

虚拟机启动

	-device virtio-scsi-pci,id=scsi
	-drive if=none,id=mpa,file=/dev/mapper/mpatha,format=raw
	-device scsi-hd,drive=mpa

## 使用SCSI Reservation [参考文档: Understanding Linux SCSI Reservation](https://www.thegeekdiary.com/understanding-linux-scsi-reservation/)

参考manual: man sg_persist

安装工具: sys-apps/sg3_utils-1.47

作用: 通过给lun进行加锁来限制修改存储的方法(allows SCSI initiators to reserve a LUN for exclusive access and preventing other initiators from making changes)

SCSI Reservation 包含两个阶段

1. Register: 注册一个保留的键值(register a reservation key)
2. Reserve: 当initiator需要使用存储时需要用这个保留的键值来管控
	(register a reservatierve the device using the same reservation key when a host need exclusive accessn key)

下面实验会在一个node上获取锁(node1),一个node上不获取锁(node2)来验证是否没有获取到锁的node就无法使用存储

下面的操作步骤都在node1上执行

假设在initiator(node1)中看到的lun为(/dev/sdc),查看其是否有注册键值(如下是没有)

	sg_persist /dev/sdc
	>> No service action given; assume Persistent Reserve In command
	>> with Read Keys service action
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x0, there are NO registered reservation keys

### Register a reservation key

注册一个保留键值(保留键需要长于8字节的十六进制字符串,比如abc123)

	sg_persist --out --register --param-sark=abc123 /dev/sdc

注册后再次查询就能看到新注册的保留键(在每个node上查看到的结果都一样)

	sg_persist /dev/sdc
	>> No service action given; assume Persistent Reserve In command
	>> with Read Keys service action
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x1, 1 registered reservation key follows:
		0xabc123

### Reserve a registered LUN on behalf of a given key

使用已注册的key进行预留

	sg_persist --out --reserve --param-rk=abc123 --prout-type=3 /dev/sdc

The –prout-type parameter specified the reservation type, from manpage, valid types including:

	1 : write exclusive
	3 : exclusive access
	5 : write exclusive – registrants only
	6 : exclusive access – registrants only
	7 : write exclusive – all registrants
	8 : exclusive access – all registrants

### View the reservation

查看预留的键值(在每个node上查看到的结果都一样)

	sg_persist -r /dev/sdc
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x1, Reservation follows:
		Key=0xabc123
		scope: LU_SCOPE,  type: Exclusive Access

### Verify the reservation

确认预留键值是否生效

在已经获取到锁的node上mount成功

	mount /dev/sdc /mnt

此时在没有获取到锁的node进行同样操作会发生错误(node2上为/dev/sda)

	mount /dev/sda /mnt
	mount: /mnt: can't read superblock on /dev/sda.

查看内核信息可以看到(reservation conflict)

	sd 4:0:0:1: reservation conflict
	sd 4:0:0:1: [sda] tag#12 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_OK cmd_age=0s
	sd 4:0:0:1: [sda] tag#12 CDB: Read(16) 88 00 00 00 00 00 00 00 00 02 00 00 00 02 00 00
	critical nexus error, dev sda, sector 2 op 0x0:(READ) flags 0x1000 phys_seg 1 prio class 0
	EXT4-fs (sda): unable to read superblock

如果node1上释放了这个锁后node2上就能使用该存储

### Release the reservation

释放预留键值

	sg_persist --out --release --param-rk=abc123 --prout-type=3 /dev/sdc

释放之后查询结果(已经没有人使用预留键值)

	sg_persist -r /dev/sdc
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x1, there is NO reservation held

### Unregister a reservation key

取消注册预留键值

	sg_persist --out --register --param-rk=abc123 /dev/sdc

查看取消注册的结果

	sg_persist  /dev/sdc
	>> No service action given; assume Persistent Reserve In command
	>> with Read Keys service action
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x2, there are NO registered reservation keys

### QEMU中使用PR锁(参考文档:docs/pr-manager.rst)

[QEMU pr-helper文档](https://www.qemu.org/docs/master/interop/pr-helper.html)

[Add SCSI-3 PR support to qemu (similar to mpathpersist)](https://bugzilla.redhat.com/show_bug.cgi?id=1464908)

1. 启动daemon进程

	sudo qemu-pr-helper

2. 启动qemu是参数配置如下(其中helper路径是在qemu/scsi/qemu-pr-helper.c代码中固定写好的)

	sudo qemu-system-x86_64 \
		...
		-device virtio-scsi \
		-object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
		-drive if=none,id=hd,driver=raw,file.filename=/dev/sdc,file.pr-manager=helper0 \
		-device scsi-block,drive=hd
		...

3. 在guest中执行上面的注册和预留锁的步骤

	linux guest通过sg_persist命令将操作发送给虚拟机中的虚拟设备后再通过socket发送给
		qemu-pr-helper,最终实现对应的功能
