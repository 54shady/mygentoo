# 二进制包软件管理和使用

## 安装二进制(BinaryPackage)的软件包

### 主机上操作(BinaryHost)

在主机上生成当前系统里所有已安装软件的binary包

	emerge -uDN @world --buildpkg

生成的所有包都在/usr/portage/packages目录里

设置BinaryHost主机(使用SSH协议)

这里将客户端root用户的公钥添加到主机root用户的authorized文件

	# cat id_rsa.pub >> /root/.ssh/authorized_keys

### 客户端操作(BinaryClient)

添加下面内容到/etc/portage/make.conf文件(BinaryHost IP 192.168.1.100)

	PORTAGE_BINHOST="ssh://root@192.168.1.100/usr/portage/packages"

安装Binary软件

	emerge -G package_name

## 使用Docker来作为(二进制包)编译主机

直接用stage4的tarball来生成当前对应的docker镜像

将stage4解压到rootfs

	tar xvf stage4.tar -C rootfs

使用下面的Dockerfile来生成docker镜像(docker build . -t binhost)

	FROM scratch
	COPY rootfs /

使用docker生成git的二进制包

	~~docker run --privileged -v /host/binary/packages:/usr/portage/packages --net=host --rm -it binhost /usr/bin/quickpkg git~~

用emerge选项来编译(使用alias方便操作)

	~~alias bpkg='docker run --privileged -v /usr/portage:/usr/portage --net=host --rm -it binhost /usr/bin/emerge -b'~~
	alias bpkg='docker run --privileged -v /path/to/a/dir/packages:/usr/portage/packages --net=host --rm -it binhost /usr/bin/emerge -b'
	bpkg git

编译当前系统所有二进制包(stage4中最好有内核代码和portage,就可以不用挂载目录)

	~~docker run --privileged -v /usr/src/linux:/usr/src/linux -v /usr/portage:/usr/portage --net=host --rm -it binhost /usr/bin/quickpkg --include-config=y "*/*"~~
	docker run --privileged -v /host/binary/packages:/tmp --net=host --rm -it binhost /usr/bin/quickpkg --include-unmodified-config=y "*/*"

客户端配置中路径对应的是host/binary/packages

	PORTAGE_BINHOST="ssh://<user>@<ip>/host/binary/packages"
