## 在同一台电脑上管理多个ssh key

在开发过程中存在同步内网和外网代码的情况,会存在需求切换ssh key的场景

假设有如下场景,本地电脑既需要从内网服务器下载代码,也需要从外网服务器下载代码

假设本地开发电脑IP 172.1.2.81

假设本地局域网内代码服务器IP 172.1.2.83

远程外网服务器地址www.rockchip.com.cn

在本地电脑上存在两个ssh key假设如下

	id_rsa.pub_code
	id_rsa_code

	id_rsa.pub_rk
	id_rsa_rk

id_rsa_code是用于和本地代码服务器通信的私钥

id_rsa_rk是用于和远程外网服务器通信的私钥

查看ssh key的代理

	ssh-add -l

若提示如下则表示系统代理没有任何key

	Could not open a connection to your authentication agent

开启系统代理

	exec ssh-agent bash

删除系统中的所有代理

	ssh-add -D

将需要使用的私钥添加到代理中

	ssh-add ~/.ssh/id_rsa_rk
	ssh-add ~/.ssh/id_rsa_code

将公钥添加到相应的远程服务器,这里不演示

在本地电脑添加ssh的配置文件(~/.ssh/config)

	# local ip 172.1.2.81
	# remote code server ip 172.1.2.83
	Host 172.1.2.83
	HostName 172.1.2.83
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_code
	user zeroway

	# rockchip
	Host rockchip
	HostName www.rockchip.com.cn
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_rk
	user zeroway

	# github
	Host github
	HostName https://github.com/54shady
	PreferredAuthentications publickey
	IdentityFile ~/.ssh/id_rsa_code
	user zeroway

对上面配置文件介个关键地方解释下

本地电脑上下载远程服务器是通过git
Host和HostName都需写为远程服务器ip

	git clone git@172.1.2.83:/code_path.git

对于外网的代码服务器,使用repo下载
在相应的代码的.repo/manifest.xml文件中

	<remote fetch="ssh://git@www.rockchip.com.cn/gerrit/" name="aosp"/>
	<remote fetch="ssh://git@www.rockchip.com.cn/gerrit/" name="rk"/>
	<remote fetch="ssh://git@www.rockchip.com.cn/repo/" name="stable"/>

其中的user需要填写对应的用户名,这里是zeroway
