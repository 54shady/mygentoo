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

搜索target,下面命令都是在root用户下操作

	iscsiadm -m discovery --type sendtargets -p targetip
	iscsiadm -m discoverydb -t st -p targetip

和target建立连接并登入

	iscsiadm -m node T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -l

登出target

	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 --logout

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
