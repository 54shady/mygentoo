# LXC Usage

## [comparation between lxc and lxd](https://blog.simos.info/comparison-between-lxc-and-lxd/)

- LXC is written in C,LXD is written in the Go language
- LXC provide command with "lxc-" prefix,LXD provides two commands, lxd(services) and lxc(CLI client)

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

在ubuntu20.04/22.04中操作安装对应软件

	snap install distrobuilder
	apt install -y debootstrap
	git clone https://github.com/lxc/distrobuilder

创建必要目录

	mkdir -p $HOME/ContainerImages/ubuntu/
	cd $HOME/ContainerImages/ubuntu/
	cp $HOME/distrobuilder/doc/examples/ubuntu.yaml ubuntu.yaml

修改ubuntu.yaml配置文件中的源如下

	source:
		downloader: debootstrap
		same_as: gutsy
		url: https://mirrors.tuna.tsinghua.edu.cn/ubuntu

构建lxd镜像

	distrobuilder build-lxd ubuntu.yaml

构建lxc镜像(将镜像文件打包到targetdir)

	distrobuilder build-lxc ubuntu.yaml targetdir
	lxc-create -n myubt -t local -- --metadata targetdir/meta.tar.xz --fstree targetdir/rootfs.tar.xz
