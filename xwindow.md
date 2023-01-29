# SSH forward X11

通过ssh转发X11来实现打开远程服务器的gui程序

- 对于单台Linux电脑,xserver和xclient都在本地,本地xserver接收xclinet
- 现在需要将远程服务器的xclinet显示到本地电脑

## 远程电脑配置(启动gui app)

远端电脑(启动图形界面的应用程序的linux)配置(/etc/ssh/sshd_ocnfig)添加如下

	X11Forwarding yes

当有电脑通过ssh远程连接到该主机时会在~/.Xauthority追加一条记录

	xauth list

## 本地电脑配置(显示远程电脑的gui app)

Linux操作如下

- 首先先ssh连接到远程服务器

linux(一般情况下已经安装来xserver)如下连接

	ssh -X user@remote # 登入到远程服务器

- 在远程服务器上打开gui app(比如这里的xclock)

通过ssh登入到远程服务器后操作

	[remote server] $ echo $DISPLAY
	localhost:10.0 # 这里会输出则表示配置成功,可自动分配或手动配置
	[remote server] $ xclock

Windows操作如下

- 安装xserver(xming),XLaunch配置display

配置如下

	=> display number 10 # 这里指定display port为10
	=> start no client

windows通过putty设置Enable X11 forwarding

配置Xdisplay location

	localhost:10.0

- 连接到服务器后启动xclock

之后再用putty连接远程服务器

	[remote server] $ echo $DISPLAY
	localhost:10.0 # 这里会输出则表示配置成功,可自动分配或手动配置
	[remote server] $ xclock

FAQ:

Warning: untrusted X11 forwarding setup failed: xauth key data not generated
需要在本地电脑的~/.ssh/config中添加如下内容,此时没有生成~/.Xauthority,DISPLAY变量为空

	ForwardX11Trusted yes

添加后警告变为如下,生成了~/.Xauthority,DISPLAY变量有值

	Warning: No xauth data; using fake authentication data for X11 forwarding.
