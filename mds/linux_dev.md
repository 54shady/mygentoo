# LINUX 开发环境搭建

## TFTP服务器搭建

- 在gentoo上安装tftp软件

	sudo emerge -v net-ftp/atftp

- 配置(使用默认安装的配置文件,修改了根目录)

	cat /etc/conf.d/atftp

内容如下

	# Config file for tftp server
	TFTPD_ROOT="/home/zeroway/github/matrix"
	TFTPD_OPTS="--daemon --user nobody --group nobody"

- 开启tftp服务(服务器IP:192.168.1.100)

	/etc/init.d/atftp start

- 在开发板上使用tftp(比如从tftp服务器上获取libfahw.so)

	tftp -g 192.168.1.100 -r lib/libfahw.so
	cp libfahw.so lib/

- 拷贝一个测试程序

	tftp -g 192.168.1.100 -r demo/matrix-pwm/matrix-pwm
	chmod +x matrix-pwm
	./matrix-pwm
