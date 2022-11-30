## ssh client 配置

新连接ssh服务器时会跳出如下提示,修改配置默认接受

	The authenticity of host can't be established.
	ECDSA key fingerprint is SHA256
	Are you sure you want to continue connecting (yes/no)?

修改/etc/ssh/ssh_config添加如下内容

	StrictHostKeyChecking accept-new

以后每次就能配合sshpass来连接

	sshpass -p <youpass> ssh user@host
