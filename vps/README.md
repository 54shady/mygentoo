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

## 浏览器配置

	set content.proxy socks://localhost:1080

## git配置代理

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
