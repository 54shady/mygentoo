# [About iSCSI Storage](https://docs.oracle.com/cd/E37670_01/E41138/html/ch17s07s01.html)

参考文档:Better_Utilization_of_Storage_Features_from_KVM_Guest_via_virtio-scsi.pdf

[参考文章:Open-iSCSI](https://wiki.archlinux.org/title/Open-iSCSI)

[参考文章:LIO](https://wiki.archlinux.org/title/ISCSI/LIO)

- iqn: iSCSI Qualified Name
- 客户端(使用存储): initiator,可以是在内核或是用户态(qemu)
	lio target和qemu target模式下:
		客户端iqn配置在文件:/etc/iscsi/initiatorname.iscsi(名字格式:InitiatorName=iqn)
		客户端的配置文件:/etc/iscsi/iscsid.conf
		客户端上可以看到target node的信息:/etc/iscsi/nodes, /etc/iscsi/send_targets
- 服务端(提供存储): target

假设客户端和服务端不在同一台服务器上

- target在服务器A, ip: 192.168.1.100, 下面用targetip代替
- initiator在服务器B

## 服务端A配置target

安装target程序

	emerge sys-block/tgt

### 使用物理磁盘作为存储

假设target服务器上有两块可用做存储的硬盘sdc,sdd(配置/etc/tgt/targets.conf)

	<target iqn.2012-01.com.mydom.host01:target1>
		direct-store /dev/sdc # LUN 1
		direct-store /dev/sdd # LUN 2
	</target>

存储卷可以是整个磁盘,分区,或是文件

	<target iqn.2012-01.com.mydom.host01:target1>
			direct-store /dev/sdb1
			direct-store /dev/sdb2
			direct-store /dev/sdd
	</target>

启动target服务

	rc-service tgtd start

查看target存储情况(I_T nexus信息, 已经连接的Initiator)

	tgt-admin -s
	tgtadm -o show -m target

### 使用虚拟磁盘作为target的后端存储

[Using shared storage with virtual disk images](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/sect-virtualization-shared_storage_and_virtualization-using_iscsi_for_storing_virtual_disk_images)

启动target服务

	rc-service tgtd start

创建虚拟磁盘作为lun(10G的sparse file和500MB的fully-allocated)

	mkdir /root/vd

	dd if=/dev/zero of=/root/vd/sparse_file.img bs=1M seek=10240 count=0
	dd if=/dev/zero of=/root/vd/shareddata.img bs=1M count=512

添加一个target(iqn.2004-04.rhel:rhel5:iscsi.kvmguest)

	tgtadm --lld iscsi --op new --mode target --tid 1 --targetname iqn.2004-04.rhel:rhel5:iscsi.kvmguest

绑定存储卷和iSCSI target里的lun

	tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 1 --backing-store /root/vd/sparse_file.img
	tgtadm --lld iscsi --op new --mode logicalunit --tid 1 --lun 2 --backing-store /root/vd/shareddata.img

查询配置好的信息

	tgtadm --lld iscsi --op show --mode target

配置允许客户端不要授权登录

	tgtadm --lld iscsi --op bind --mode target --tid 1 --initiator-address ALL

删除指定target上的lun

	tgtadm --lld iscsi --op delete --mode logicalunit --tid 1 --lun 1
	tgtadm --lld iscsi --op delete --mode logicalunit --tid 1 --lun 2

根据target id 删除一个target

	tgtadm --lld iscsi --op delete --mode target --tid 1

## 客户端B配置initiator

### 对应initiator在客户端的内核中的场景1,2(qemu target模式)

列出所有lun

	iscsi-ls --show-luns iscsi://targetip

安装对应的软件

	emerge sys-block/open-iscsi

启动iscsid

	rc-service iscsid start

搜索target,下面命令都是在root用户下操作(当target有更新或ip地址更新则需要执行)

	iscsiadm -m discovery --type sendtargets -p targetip
	iscsiadm -m discoverydb -t st -p targetip

和target建立连接并登入(login)

	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -l

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

	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -u

### 1. initiator在客户端内核中,以块设备的方式提供存储(qemu target 模式)

将这两块盘(以块设备的方式)给虚拟机使用

	-device virtio-scsi-pci,id=scsi
	-device scsi-hd,drive=sdb -drive if=none,id=sdb,file=/dev/sdb,cache=writeback,format=raw
	-device scsi-hd,drive=sdc -drive if=none,id=sdc,file=/dev/sdc,cache=writeback,format=raw

同步target端信息

	iscsiadm -m discoverydb -t st -p targetip -o new --discover
	iscsiadm -m discoverydb -t st -p targetip -o update --discover
	iscsiadm -m discoverydb -t st -p targetip -o delete --discover

### 2. initiator在客户端内核中,以vhost方式提供存储(lio target 模式)

在服务器B上安装targetcli软件(tool for manageing linux kernel target, lio)

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

### 3. initiator在qemu中(libiscsi 模式: user space iSCSI initiator)

编译qemu支持用户态的iscsi(--enable-libiscsi)

这里使用的lun类型的硬盘,所以不需要执行上面的登录操作来将
后端存储映射到本地的块设备,而是配置lun设备由qemu中的initiator来进行映射

虚拟机使用(这里的lun的值就是上面查询到的)

	-device virtio-scsi-pci,id=scsi
	-drive if=none,format=iscsi,transport=tcp,portal=targetip:3260,target=iqn.2012-01.com.mydom.host01:target1,id=diska,lun=1
	-device scsi-hd,drive=diska

或者用iSCSI URL Format的连接

	-device virtio-scsi-pci,id=scsi
	-drive if=none,file=iscsi://targetip/iqn.2012-01.com.mydom.host01:target1/1,id=diska
	-device scsi-hd,drive=diska

如果要在guest里支持sg_persist来操作pr锁需要配置scsi-block设备(scsi-hd不支持sg_persist命令)

	-device virtio-scsi,id=scsi
	-drive if=none,format=iscsi,transport=tcp,portal=targetip:3260,target=iqn.2012-01.com.mydom.host01:target1,id=diska,lun=1
	-device scsi-block,drive=diska

通过参数来设置iqn

	-device virtio-scsi-pci,id=scsi
	-drive if=none,format=raw,file=iscsi://targetip/iqn.2012-01.com.mydom.host01:target1/1,id=diska,file.initiator-name=iqn.1999-1218.com.sara:host1
	-device scsi-hd,drive=diska

### 4. multipath(TODO)

修改服务器A(target端)的配置(/etc/tgt/targets.conf)如下

	<target iqn.2012-01.com.mydom.host01:target1>
		direct-store /dev/sdc # LUN 1
	</target>
	<target iqn.2012-01.com.mydom.host01:target2>
		direct-store /dev/sdd # LUN 2
	</target>

在initiator端(服务器B)上查询target情况能发现有两个target

	iscsiadm -m discovery --type sendtargets -p targetip

initiator端安装软件multipath软件

	emerge sys-fs/multipath-tools

先确保退出之前的登录

	iscsiadm -m session -P 3 # 查询是否还有会话
	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -u

重新登录

	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target1 -p targetip:3260 -l
	iscsiadm -m node -T iqn.2012-01.com.mydom.host01:target2 -p targetip:3260 -l

虚拟机启动

	-device virtio-scsi-pci,id=scsi
	-drive if=none,id=mpa,file=/dev/mapper/mpatha,format=raw
	-device scsi-hd,drive=mpa

## 使用SCSI Reservation

[参考文档: Understanding Linux SCSI Reservation](https://www.thegeekdiary.com/understanding-linux-scsi-reservation/)

参考manual: man sg_persist

安装工具: sys-apps/sg3_utils-1.47

I_T nexus : persistent reservation is held by so-called I_T nexus, the combination of initiator ID and target ID

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

### 1. Register a reservation key

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

### 2. Reserve a registered LUN on behalf of a given key

使用已注册的key进行预留

	sg_persist --out --reserve --param-rk=abc123 --prout-type=3 /dev/sdc

The –prout-type parameter specified the reservation type, from manpage, valid types including:

	1 : write exclusive
	3 : exclusive access # 独占:持锁者独占存储
	5 : write exclusive – registrants only # 共享:多个register共享存储,只有一个持锁者
	6 : exclusive access – registrants only
	7 : write exclusive – all registrants
	8 : exclusive access – all registrants

#### 共享存储

其中type=5允许多node共享存储需要按照下面步骤顺序操作(多个register,一个reserver holder)

1. guestA register key abc123

	sg_persist --out --register --param-sark=abc123 /dev/sda

2. guestB register key abc456

	sg_persist --out --register --param-sark=abc456 /dev/sda

3. guestA reserve key abc123 with --prout-type=5

	sg_persist --out --reserve --param-rk=abc123 --prout-type=5 /dev/sda

4. 分别在guestA和guestB中同时使用存储(数据需要umount在mount后才能同步)

	mount /dev/sda /mnt
	write to /mnt/
	umount /mnt

5. 在guestA中释放和取消注册

	sg_persist --out --release --param-rk=abc123 --prout-type=5 /dev/sda
	sg_persist --out --register --param-rk=abc123 /dev/sda

6. 在guestB中释放和取消注册

	sg_persist --out --register --param-rk=abc456 /dev/sda

#### 抢占模式

使用type=3的抢占式锁的使用(使用者1中sdc和抢占者中sda为同一存储)

使用者1使用key:abc123来加锁使用(被抢占后存储变为只读)

	sg_persist --out --register --param-sark=abc123 /dev/sdc
	sg_persist --out --reserve --param-rk=abc123 --prout-type=3 /dev/sdc

抢占者使用key:123abc来进行抢占(需要不同的initiator)

	sg_persist --out --register --param-sark=123abc /dev/sda
	sg_persist --out --preempt --param-rk=123abc --param-sark=abc123 --prout-type=3 /dev/sda

同理使用者1还可以继续抢占回来(假设还是使用key:abc123)

	sg_persist --out --register --param-sark=abc123 /dev/sdc
	sg_persist --out --preempt --param-rk=abc123 --param-sark=123abc --prout-type=3 /dev/sdc

### 3. View the reservation

查看预留的键值(在每个node上查看到的结果都一样)

	sg_persist -r /dev/sdc
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x1, Reservation follows:
		Key=0xabc123
		scope: LU_SCOPE,  type: Exclusive Access

### 4. Verify the reservation

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

### 5. Release the reservation

释放预留键值

	sg_persist --out --release --param-rk=abc123 --prout-type=3 /dev/sdc

释放之后查询结果(已经没有人使用预留键值)

	sg_persist -r /dev/sdc
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x1, there is NO reservation held

### 6. Unregister a reservation key

取消注册预留键值

	sg_persist --out --register --param-rk=abc123 /dev/sdc

查看取消注册的结果

	sg_persist  /dev/sdc
	>> No service action given; assume Persistent Reserve In command
	>> with Read Keys service action
	  ATA       MG04ACA400N       FJ8J
	  Peripheral device type: disk
	  PR generation=0x2, there are NO registered reservation keys

### QEMU中使用PR锁

参考文档:docs/pr-manager.rst

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

- 因为操作系统限制了不允许发送persistent reservation SCSI commands给非特权程序
- 所以需要在qemu中添加一个pr-manager-helper(persistent reservation manager: pr-manager)
- pr-manager通过socket来转发命令给有特权的外部helper程序qemu-pr-helper
- 只有PERSISTENT RESERVE OUT/IN命令传给pr-manager其余的命令还是传给qemu处理
- persistent reservation helper: qemu-pr-helper
- persistent reservation manager: pr-manager-helper
- 在host的内核中会检测guest通过virtio-blk和virtio-scsi使用qemu target模式发过来的SCSI commands
- libvirt启动的虚拟机是已qemu user的权限是缺少CAP_SYS_RAWIO
	所以像persistent reserve和write same的scsi命令都是无法使用的,除非kvm是用root user启动

整体的框图如下

               SCSI commands
		guest---------------+
                            |
                            |
	+-----------------------|-------------+
	|  qemu     			V   	      |
	|			+-------[scsi-block]      |
    | other     |           |             |
    | command   |           | PR-IN/OUT   |
    |           V           V             |  socket
	|     [scsi core]   [pr-manager]------|------------> qemu-pr-helper
	|								      |
	+-------------------------------------+

3. 在guest中执行上面的注册和预留锁的步骤

	linux guest通过sg_persist命令将操作发送给虚拟机中的虚拟设备后再通过socket发送给
		qemu-pr-helper,最终实现对应的功能

## Debug ISCSI

查看scsi设备

	lsscsi -i
	lsblk --scsi

什么是direct-lun

	direct-lun is passed to qemu process as /dev/mapper/$scsi_is

### libiscsi库环境变量设置

通过环境变量设置调试级别和相关tcp参数

	LIBISCSI_DEBUG=3 LIBISCSI_TCP_USER_TIMEOUT=1 qemu-system-x86_64 ...

### 使用perf调试iscsi

[参考文章using-tracepoints-to-debug-iscsi](https://blogs.oracle.com/linux/post/using-tracepoints-to-debug-iscsi)

查看已支持的tracepoints

	sudo perf list 'iscsi:*'

查看某个tracepoints

	sudo perf trace --no-syscalls --event="iscsi:iscsi_dbg_conn"
	sudo perf trace --no-syscalls --event="iscsi:iscsi_dbg_session"

### 使用wireshark调试iscsi

用tshark过滤抓的包

	tshark -r /path/to/cap-iscsi.pcapng -Y "scsi" -T fields -e frame.number -e ip.addr -e _ws.col.Info | grep "Persistent"

使用tsharkdocker抓包

	docker run --rm -it --privileged --network host \
		toendeavour/tshark \
		-i eth0 -Y "scsi" -T fields -e frame.number -e ip.addr -e _ws.col.Info | grep "Persistent"

使用tcpdump抓包后使用wireshark查看

	sudo tcpdump -i eth0 -vvv -w /path/to/cap-iscsi.pcapng
	sudo wireshark /path/to/cap-iscsi.pcapng

### qemu中执行scsi命令对应的函数

可以通过开启下面的trace来查看

	(qemu) trace-event scsi_generic_send_command on

### 通过gdb打印出cdb

启动gdb调试虚拟机

	sudo gdb --args /path/to/src/qemu/build/x86_64-softmmu/qemu-system-x86_64 \
		-smp 2 -m 1G -enable-kvm \
		-device virtio-scsi,id=scsi \
		-drive if=none,format=raw,file=iscsi://targetip/iqn.2012-01.com.mydom.host01:target1/1,id=diska,file.initiator-name=iqn.1999-1218.com.sara:host1 \
		-device scsi-block,drive=diska -serial mon:telnet::4444,server=on,wait=off

在qemu/block/iscsi.c的iscsi_aio_ioctl函数里下面对应行打上断点

	if (iscsi_scsi_command_async(iscsi, iscsilun->lun, acb->task
	(gdb) p /x acb->task->cdb

### 关于qemu中scsi-hd和scsi-block设备

scsi-hd是模拟设备,而scsi-block可以将scsi命令进行透传到后端再调用libiscsi处理

当使用scsi-hd设备,在虚拟机中执行sg_persist命令会返回不支持(command not supported),可开启如下调试

	(qemu) trace-event scsi_disk_emulate_command_UNKNOWN on

因为scsi-hd命令对于PR IN/OUT命令都进行丢弃

## FAQ

1. 当出现锁没有被正确释放导致无法访问时,服务端需要手动停止存储再开启,客户端需要重新登录

	/etc/init.d/tgtd zap
	/etc/init.d/tgtd stop
	kill -9 `pgrep tgtd`
	/etc/init.d/tgtd start

2. 关于iscsi多session(rcf 3720: Consequences of the Model)

	通过每个ISID(session id)来区分一个连接,
	所以即便是同一个initiator连接同一个target也是可以支持多session的
