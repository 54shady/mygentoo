## Samba 服务器搭建[推荐使用docker搭建参考这里](./docker/README.md)

Samba安装和配置

	sudo emerge -v net-fs/samba

拷贝一个配置文件,在此基础上修改

	sudo cp /etc/samba/smb.conf.default /etc/samba/smb.conf

添加用户并设置密码

	sudo smbpasswd -a zeroway

开启服务

	sudo /etc/init.d/samba start

设置某个目录为共享目录

在/etc/samba/smb.conf最后添加下面内容

	[myshare]
	comment = zeroway's share on gentoo
	path = /home/zeroway/Downloads
	valid users = zeroway
	browseable = yes
	guest ok = yes
	public = yes
	writable = no
	printable = no
	create mask = 0765

samba高级设置

单独为使用samba的用户设置一个组,该组成员不能通过终端登入,只能访问samba服务

新建一个samba组

	groupadd samba

添加一个hsdz的用户到该组(samba)

使用/bin/false作为shell,不创建宿主目录,不设置用户密码

	useradd -M -g samba -s /bin/false hsdz

注意:在/etc/samba/smb.conf里要添加这个用户访问权限

添加samba用户并设置访问密码

	smbpasswd -a hsdz
	smbpasswd hsdz

重启samba服务后即可访问

使用samba客户端测试

	smbclient -U hsdz -L //server_ip_addr/myshare

将远程目录挂载到本地

	sudo mount.cifs //server_ip/myshare /mnt/dst -o username=hsdz,password=1
