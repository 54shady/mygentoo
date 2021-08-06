# VPS服务器配置

## trojan配置

- 服务器ip 11.22.33.44
- 密码this_passwd
- 端口号: 1080

安装 net-proxy/trojan


修改配置文件

	sed -e 's/server_ip_stub/11.22.33.44/' -e 's/password_stub/this_passwd/' client.json

服务端启动trojan(客户端同理)

	trojan -c server.json

### http代理配置

torjan默认只有socks5代理,需要通过(net-proxy/privoxy)来转发支持http代理

修改配置文件/etc/privoxy/config如下

	listen-address  0.0.0.0:8118 		#监听任意ip的8118端口
	forward-socks5t / 127.0.0.1:1080 .  #设置转发到本地的socks5代理客户端端口
	forward 10.*.*.*/ . 				#内网地址不走代理
	forward .abc.com/ . 				#指定域名不走代理

启动privoxy后查看privoxy运行情况

	lsof -i :8118

## 单独配置浏览器使用代理

使用socks代理

	set content.proxy socks://localhost:1080

使用http代理

	set content.proxy http://localhost:8118

## 单独配置git使用代理(http代理相应替换即可)

Create a file gitproxy.sh with content:

	#!/bin/sh
	nc -X 5 -x 127.0.0.1:1080 "$@"

Edit ~/.gitconfig

	[core]
		gitproxy=/path/to/gitproxy.sh

	[http]
		proxy=socks5://127.0.0.1:1080

	[https]
		proxy=socks5://127.0.0.1:1080

Edit /etc/ssh/ssh_config to change global setting (or ~/.ssh/config for special host)

	ProxyCommand nc -X 5 -x 127.0.0.1:1080 %h %p

## 全局配置使用代理

在shell脚本中添加如下函数source后可手动开关

	function openProxy() {
		export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
		export http_proxy="http://127.0.0.1:8118"
		export https_proxy=$http_proxy
		echo -e "OpenProxy"
	}

	function closeProxy() {
		unset http_proxy
		unset https_proxy
		echo -e "CloseProxy"
	}

带开全局代理后在终端输入下面命令有输出则表示代理开启成功

	curl -i google.com
