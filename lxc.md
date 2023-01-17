# [LXC Usage](https://linuxcontainers.org/)

## [LXD和LXC的区别 comparation between lxc and lxd](https://blog.simos.info/comparison-between-lxc-and-lxd/)

- LXC is written in C,LXD is written in the Go language
- LXC provide command with "lxc-" prefix,LXD provides two commands, lxd(hypervisor) and lxc(CLI client)
- LXC is system containers(like docker), LXD is a hypervisor(can run both system containers and virtual machine)

## 基本安装和查询信息

安装软件和模板

	apt install -y lxc lxc-templates

容器模板在/usr/share/lxc/templates下

查看lxc配置信息

	lxc-config -l

	lxc.default_config
	lxc.lxcpath
	lxc.bdev.lvm.vg
	lxc.bdev.lvm.thin_pool
	lxc.bdev.zfs.root
	lxc.cgroup.use
	lxc.cgroup.pattern

查看具体配置项目(不同用户使用的不一样)

	lxc-config lxc.default_config
	lxc-config lxc.lxcpath

## 手动构造容器(假设使用root用户操作,默认lxc目录/var/lib/lxc)

### 创建容器必要目录和文件

创建本地容器ubt(目录名就是容器名),和对应的配置文件

	mkdir /var/lib/lxc/ubt
	touch config

此时就能看到有一个容器

	lxc-ls

创建根文件系统(这里使用ubuntu jammy-base-arm64.tar.gz为例)

	cd /var/lib/lxc/ubt/
	mkdir rootfs
	tar xvf jammy-base-arm64.tar.gz -C rootfs

修改容器配置(config)文件,添加如下内容

	lxc.rootfs.path = /var/lib/lxc/ubt/rootfs

使用前台模式运行容器

	lxc.start -F ubt /bin/bash

## 使用模板创建容器

安装模板(/usr/share/lxc/templates/)

	apt install -y lxc-templates

使用默认参数创建容器

	lxc-create -t ubuntu -n ubt -- -d

创建amd64架构的ubuntu(jammy)容器

	lxc-create -t ubuntu -n ubt -- -r jammy -a amd64 -d -v minbase --mirror https://mirrors.tuna.tsinghua.edu.cn/ubuntu/

会从网络上下载根文件系统到对应目录(/var/cache/lxc/jammy/rootfs-amd64),同手动创建

## 构建容器镜像

[使用distrobuilder构建容器镜像](https://github.com/lxc/distrobuilder)

[参考文章1:AlmaLinux/distrobuilder](https://github.com/AlmaLinux/distrobuilder)

[参考文章2: run windows on lxd](https://blog.simos.info/how-to-run-a-windows-virtual-machine-on-lxd-on-linux/)

[参考文档3: distrobuilder readthedocs](https://distrobuilder.readthedocs.io/en/latest/)

### 使用模板构建lxc/lxd容器

在ubuntu20.04/22.04中操作安装对应软件

	snap install distrobuilder --classic
	apt install -y debootstrap
	git clone https://github.com/lxc/distrobuilder

创建必要目录

	mkdir -p $HOME/ContainerImages/ubuntu/
	cd $HOME/ContainerImages/ubuntu/
	cp $HOME/distrobuilder/doc/examples/ubuntu.yaml ubuntu.yaml

修改ubuntu.yaml配置文件(使用tuna的源)

	source:
		downloader: debootstrap
		same_as: gutsy
		url: https://mirrors.tuna.tsinghua.edu.cn/ubuntu

构建lxd镜像,并导入

	distrobuilder build-lxd ubuntu.yaml targetdir
	lxc image import targetdir/lxd.tar.xz targetdir/rootfs.squashfs --alias ubuntu-jammy

构建lxc镜像(将镜像文件打包到targetdir)

	distrobuilder build-lxc ubuntu.yaml targetdir
	lxc-create -n myubt -t local -- --metadata targetdir/meta.tar.xz --fstree targetdir/rootfs.tar.xz

#### LXD的一些基本操作

列出所有lxd容器镜像的别名

	lxc image list -c l

查看运行中的lxd容器

	lxc ls

启动lxd容器(lxc launch <lxdimage> <containername>)

	lxc launch ubuntu-jammy ubt

停止容器,删除容器

	lxc stop ubt
	lxc delete ubt

查看镜像名,并重命名

	lxc image list
	lxc image alias rename old-image-name new-image-name

进入到运行的容器的shell中

	lxc exec ubt -- /bin/bash

执行命令或脚本

	lxc exec ubt -- command
	lxc exec ubt -- apt update
	lxc exec ubt -- /path/to/script

### 使用lxd运行windows系统(lxd中会运行qemu来启动虚拟机)

安装必要软件,重新打包iso

	apt install -y libguestfs-tools wimtools
	distrobuilder repack-windows --drivers virtio-win.iso Win10_20H2_Chinese_x64.iso Windows-repacked.iso

创建磁盘

	lxc init win10 --empty --vm -c security.secureboot=false
	lxc config device override win10 root size=30GiB
	lxc config device add win10 iso disk source=/path/to/Windows-repacked.iso boot.priority=10

安装spice客户端并启动windows系统

	apt install -y virt-viewer
	lxc start win10 --console=vga
