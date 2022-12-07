# Docker Usage

## Docker本质

docker利用主机资源跑rootfs

下载一个docker image来验证(后续会用gentoo制作任何镜像)

	docker pull alpine

将这个docker镜像保存在本地并导出其rootfs

	docker save -o alp.tar alpine:latest
	tar xvf alp.tar //可以发现有个目录,这个目录中有个文件layer.tar
	tar xvf layer.tar -C rootfs //解压这个layer.tar到rootfs目录

现在来逆向docker镜像的过程(将这个rootfs打包成一个docker镜像)

写一个Dockerfile内容如下

	FROM scratch
	COPY rootfs /
	ENTRYPOINT ["/bin/sh"]

执行命令生成docker镜像

	docker build . -t myimage

测试运行生成的docker镜像

	docker run -it --rm myimage

## 基础使用

下载基础image

	docker pull centos:centos7

下载不同架构镜像(比如在x86下下载arm的镜像)

	docker pull --platform=linux/arm64 centos:centos8

查询dockerhub上镜像tags

	wget -q https://registry.hub.docker.com/v1/repositories/centos/tags -O - | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'

查看系统中的image

	docker images

重命名镜像

	docker image tag oldimage:oldtag newimage:newtag

交互式运行image,运行起来后就叫container

	docker run -it --name myctos centos:centos7

查看当前container情况

	docker ps -l

删除container

	docker rm myctos

后台运行container

	docker run -d -it --name myctos centos:centos7

查看某个container后进入执行

	docker ps -l
	docker exec -it myctos bash
	docker exec -it myctos sh # 有些容器中没有bash

后台运行容器(并挂在本地目录share2docker到container中的mnt下)

	docker run -d --network host -it -v /home/anonymous/share2docker/:/mnt --name mysamba centos:centos7

开启全部container

	docker start $(docker ps -q)

停止全部container

	docker stop $(docker ps -q)

删除全部container

	docker rm $(docker ps -aq)

## Samba Server

执行相应操作

	docker exec mysamba sed -i 's/keepcache=0/keepcache=1/' /etc/yum.conf
	docker exec mysamba yum update -y
	docker exec mysamba yum install -y python3 samba

将容器改动提交成镜像

	docker commit -m 'samba,python3' mysamba samba:v1

将镜像保存到本地

	docker save -o sambaimage.tar samba:v1

删除当前已经存在的镜像

	docker rmi -f samba:v1

使用时将本地镜像导出即可

	docker load < sambaimage.tar

通过制作的镜像启动容器

	docker run -d -it --name sambademo -p 139:139 -p 445:445 samba:v1

进入容器添加用户

	docker exec -it sambademo bash
	# smbpasswd -a root

使用pdbedit查看容器里samba用户

	docker exec samba pdbedit -L

启动samba服务

	docker exec sambademo smbd
	docker exec sambademo nmbd

### 使用samba docker镜像

[参考文件samba.sh](./samba.sh)

## NFS Server

[参考镜像 docker-nfs-server](https://github.com/ehough/docker-nfs-server)

使用的[Dockerfile](./nfs/Dockerfile)

镜像是在alpine的基础上制作的

	docker build . -t alpine/nfs

主机上手动加载响应的驱动

	modprobe nfs
	modprobe nfsd
	modprobe rpcsec_gss_krb5

让docker启动时自动加载,启动命令添加如下

	-v /lib/modules:/lib/modules:ro \
	--cap-add SYS_MODULE \

启动镜像(在Dockerfile中已经设置好了默认的目录/share)

	docker run -d --net=host --rm --privileged -v /host/path/to/share:/share alpine/nfs

手动指定exports文件(exports.txt), 内容如下

	/golden *(rw,sync,no_root_squash)
	/iso *(rw,sync,no_root_squash)
	/app *(rw,sync,no_root_squash)

启动docker用如下命令(自动加载对应驱动模块)

	docker run -d --restart always --net=host --privileged \
		-v /host/path/to/share:/share \
		-v /host/path/to/iso:/iso \
		-v /host/path/to/app:/app \
		-v /lib/modules:/lib/modules:ro \
		--cap-add SYS_MODULE \
		-v /path/to/exports.txt:/etc/exports alpine/nfs

在客户端查看该nfs共享(hostip填写主机的ip地址)

	showmount -e <hostip>

客户端挂载该共享

	mount -t nfs -o nolock,vers=3 hostip:/share/ /local/path/to/mount

## Web server(nginx)

下载nginx的docker镜像

	docker pull nginx

创建对应的容器,映射本地端口999到container里的80端口(path-to-html下时html的网页文件)

	docker run -d --name web -p 999:80 -v /path-to-html-dir:/usr/share/nginx/html nginx

在浏览器中访问ip:999即可

配置nginx支持多个网页([default.conf](./web/default.conf)中添加如下)
将网页内容放在/kernel下,访问http://serverip/kdoc时就是访问这个目录

	# http://serverip/kdoc
	location /kdoc {
		alias /kernel;
		index index.html index.htm;
	}

启动docker配置多个目录([index.html参考这里](./web/index.html))

	docker run -d --restart always --name web -p 80:80 \
		-v /path-to-webroot:/usr/share/nginx/html \
		-v /path-to-default.conf:/etc/nginx/conf.d/default.conf \
		-v /path-to-qemu-src/docs/_build:/qemu \
		-v /path-to-linux/Documentation/output:/kernel \
		-v /path-to-sharedir:/share \
		nginx

## prometheus and grafana

	docker run -d --name myprometheus -p 9090:9090 -v /path-cotain-prometheus.yml:/etc/prometheus prom/prometheus:v2.30.0
	docker run -d --name mygrafana -p 3000:3000 --name gfn grafana/grafana

## [Running graphic application in a container](https://www.spice-space.org/demos.html)

### 例子1: Fedora Example

使用下面的Dockerfile制作相应的镜像

	FROM fedora:27
	RUN dnf install -y xorg-x11-server-Xspice xdg-utils
	EXPOSE 5900/tcp
	ENV DISPLAY=:1.0
	CMD Xspice --port 5900 --disable-ticketing $DISPLAY  > /dev/null 2>&1 & /usr/bin/bash

制作打包镜像

	docker build -t xspice:v0.1 .

其中Dockerfile里

	RUN 后面的操作会在制作镜像时自动执行
	CMD 后面的操作会在启动镜像时执行

启动容器进入后安装一个图形界面的软件(tuxmath)用于验证测试

	docker run -it -p 5901:5900 --name xspicetst xspice:v0.1
	dnf install -y tuxmath && tuxmath

使用spice客户端进行连接

	remote-viewer spice://localhost:5901

### 例子2: [xorg-spice-html5 in docker](https://github.com/54shady/xspice)

### 例子3: Ubuntu Xfce example

使用[Dockerfile](spice/Dockerfile)编译镜像

	docker build . -t spicexfce

通过修改环境变量(指定用户名为test)来启动容器,默认启动xfce会话

	docker run -p 5900:5900 -e SPICE_USER=test -e SPICE_UID=1000 -v /home/test:/home/test -e SPICE_PASSWD="0" -e SPICE_LOCAL="en_US.UTF-8" -e SPICE_RES="1920x1080" spicexfce

或者通过设置RUNIT运行新的程序比如umlet(其他参数用默认)

	drun -p 5900:5900 -e RUNIT="java -jar /usr/share/java/umlet.jar" spicexfce

连接容器

	remote-viewer spice://localhost:5900

### 例子4:运行容器中的图形程序(需要主机有xserver)

运行eclipse的Dockerfile内容如下

	FROM java

	ARG ECLIPSE_URL='http://eclipse.mirror.rafal.ca/technology/epp/downloads/release/neon/R/eclipse-java-neon-R-linux-gtk-x86_64.tar.gz'
	RUN mkdir -p /opt && curl $ECLIPSE_URL | tar -xvz -C /opt

	CMD ["/opt/eclipse/eclipse"]

或者直接下载对应的镜像使用

	docker pull psharkey/eclipse

运行镜像(此操作同样使用例子3),容器中的图形程序作为xclient连接host的xserver

	docker run --rm -it --privileged \
		--network=host \
		-v ~/.Xauthority:/root/.Xauthority \
		-e DISPLAY=':0' \
		-e "TZ=America/Chicago" \
		psharkey/eclipse

授权信息按上面方式映射进去,也可以如下操作添加

host上查看xauth token信息

	xauth list

在容器中添加host的xauth

	xauth add <token>

用下面的Dockerfile将例子3中运行程序改一下

	FROM spicexfce
	ENTRYPOINT ["java", "-jar",  "/usr/share/java/umlet.jar"]

	docker build . -t umlet

	docker run --rm -it --privileged \
		--network=host \
		-v ~/.Xauthority:/root/.Xauthority \
		-e DISPLAY=':0' \
		-e "TZ=America/Chicago" \
		umlet

## [running arm64 docker image on x86 host](https://www.stereolabs.com/docs/docker/building-arm-container-on-x86/)

[docker image: qemu-user-static](https://hub.docker.com/r/multiarch/qemu-user-static)

在x86机器上运行arm64的docker镜像,先下载对应的镜像

	docker pull arm64v8/centos:7

下载qemu static的镜像

	docker pull multiarch/qemu-user-static

注册各个平台的可执行程序接口

	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

在x86机器上运行arm的docker镜像

	docker run --platform=linux/arm64/v8 -it arm64v8/centos:7

## 使用gentoo来制作busybox的docker镜像

编译相关的rootfs

	ROOT=/tmp/rootfs emerge busybox

Dockerfile内容如下

	FROM scratch
	COPY rootfs /
	ENTRYPOINT ["/bin/busybox", "sh"]

打包生成docker镜像

	docker build . -t mybusybox

测试生成的镜像

	docker run -it --rm mybusybox
