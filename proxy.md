## PROXY(配置系统代理/etc/env.d/01proxy)

代理服务器的http代理是(192.168.1.100:1234)

	export HTTP_PROXY="192.168.1.100:1234"
	export HTTPS_PROXY="192.168.1.100:1234"
	export RSYNC_PROXY="192.168.1.100:1234"
	export ALL_PROXY="192.168.1.100:1234"

	export http_proxy="192.168.1.100:1234"
	export https_proxy="192.168.1.100:1234"
	export rsync_proxy="192.168.1.100:1234"
	export all_proxy="192.168.1.100:1234"

修改完执行env-update即可(参考)[https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/EnvVar#The_env.d_directory]

