# LXC Usage

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

	lxc-create -t ubuntu -n myubt

会从网络上下载根文件系统到对应目录,同手动创建
