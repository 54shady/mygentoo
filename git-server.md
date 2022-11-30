## Git 服务器搭建

### 服务器配置

分区只分了/boot / swap三个分区 (/etc/fstab内容如下)

	/dev/sda2       /boot   ext4    defaults,noatime        0       2
	/dev/sda3       none    swap    sw      0       0
	/dev/sda4       /       ext4    noatime 0       1

静态IP地址配置 (/etc/conf.d/net)

	config_eth0="192.168.7.100 netmask 255.255.255.0"
	routes_eth0="default via 192.168.7.1"
	dns_servers_eth0="192.168.7.1 8.8.8.8"

安装git

	emerge dev-vcs/git

添加git用户

	groupadd git
	useradd -m -g git -d /var/git -s /bin/bash git

编辑/etc/conf.d/git-daemon内容如下

	GIT_USER="git"
	GIT_GROUP="git"

启动相应服务

	/etc/init.d/git-daemon start

添加开机启动

	rc-update add git-daemon default

### 配置客户端的SSH keys

在客户端执行

	ssh-keygen -t rsa

将客户端生成的id_rsa.pub里的内容拷贝到服务器上下面的文件里

	/var/git/.ssh/authorized_keys

### 服务器创建仓库

服务器上创建仓库(在服务器上操作,ip:192.168.7.100)

	# su git
	$ cd /var/git
	$ mkdir /var/git/newproject.git
	$ cd /var/git/newproject.git
	$ git init --bare

### 客户端操作仓库

在客户端(ip:192.168.7.101)上把要添加文件到刚才创建的仓库

	$ mkdir ~/newproject
	$ cd ~/newproject
	$ git init
	$ touch test
	$ git add test
	$ git config --global user.email "M_O_Bz@163.com"
	$ git config --global user.name "zeroway"
	$ git commit -m 'initial commit'
	$ git remote add origin git@192.168.7.100:/var/git/newproject.git
	$ git push origin master

在其他客户端(client)克隆该仓库

	git clone git@192.168.7.100:/newproject.git
