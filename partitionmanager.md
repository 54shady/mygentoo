### 安装partitionmanager

软件安装

	emerge sys-block/partitionmanager

安装后需要使用root权限启动软件才能查看完整的磁盘信息

我使用的普通用户zeroway,所以要用sudo partitionmanager

但是发现提示下面的错误:

	partitionmanager: cannot connect to X server :0

原因是root用户没有加入到zeroway访问X server的权限里

只要添加就可以了

	xhost local:root

现在就能用sudo partitionmanager启动软件了

以后凡是需要有root权限的GUI程序都可以这样

例如porthole(portage图形安装方式)软件也是一样的

