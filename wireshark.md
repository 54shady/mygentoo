# Wireshark使用

## 设置root-privileges

将当前用户添加到wireshark组

	sudo groupadd wireshark
	sudo usermod -a -G wireshark $USER
	sudo chgrp wireshark /usr/bin/dumpcap
	sudo chmod o-rx /usr/bin/dumpcap
	sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
	sudo getcap /usr/bin/dumpcap

## 定位路由问题导致无发上网

有问题前的路由情况

ip ro
	default via 10.52.64.1 dev eth0
	10.52.64.0/21 dev eth0 proto kernel scope link src 10.52.64.183
	172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
	192.168.16.0/20 dev docker_gwbridge proto kernel scope link src 192.168.16.1
	192.168.48.0/20 dev br-38e02b18ddc2 proto kernel scope link src 192.168.48.1 linkdown

发现ping不同dns服务器

	ping 192.168.58.94

arping 192.168.58.94 的输出会显示当前使用那张网卡
	ARPING 192.168.58.94 from 192.168.48.1 br-38e02b18ddc2

	ping 192.168.58.94 -I eth0才能ping通

删除异常的路由

	sudo ip ro del 192.168.48.0/20

用dns字符串来过滤抓包

	sudo tshark -i eth0 -Y "dns"

抓icmp协议包

	sudo tshark -i eth0 -f icmp
