## ssh client 配置

1. 新连接ssh服务器时会跳出如下提示,修改配置默认接受

	The authenticity of host can't be established.
	ECDSA key fingerprint is SHA256
	Are you sure you want to continue connecting (yes/no)?

修改/etc/ssh/ssh_config添加如下内容

	StrictHostKeyChecking accept-new

以后每次就能配合sshpass来连接

	sshpass -p <youpass> ssh user@host

2. git pull等操作时发现有如下错误

	kex_exchange_identification: Connection closed by remote host

此时用ssh -T 测试也是报同样的错误

	ssh -T git@github.com

可以将github的连接端口从22改成443(修改~/.ssh/config)添加如下

	Host github.com
		HostName ssh.github.com
		User git
		Port 443

再次使用ssh -T测试

	ssh -T git@github.com
	Hi xxx! You've successfully authenticated, but GitHub does not provide shell access.

3. 新安装好linux发现sshd启动不了(Failed to start OpenBSD Secure Shell server)

使用sshd -T查看报什么错误

	sshd: no hotskeys available

添加key

	ssh-keygen -A
