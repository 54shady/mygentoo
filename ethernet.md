# nmcli (NetworkManager Command Line Interface)

- nmcli是客户端,NetworkManager是后台服务
- nmcli是nm-applet的替代品

命令格式如下

	nmcli [OPTIONS] OBJECT { COMMAND | help }

其中OBJECT有如下几个

	general, networking, radio, connection, device, agent, and monitor

OPTIONS中

	-t, terse可用于输出便于脚本中处理的格式

[RedHat: config ip with nmcli](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_ip_networking_with_nmcli)

## 基本使用

查看设备和连接类型

	nmcli -f DEVICE,TYPE device

查看设备状态

	nmcli -p device

新建一个static ethernet连接(使用网口接口enp0s31f6)命名为Myeth0

	nmcli con add type ethernet con-name Myeth0 ifname enp0s31f6 ip4 192.168.2.101/24 gw4 192.168.2.1

查看连接情况

	nmcli connection show

查看更多详细情况

	nmcli -p con show Myeth0

开启连接和关闭连接

	nmcli connection up Myeth0
	nmcli connection down Myeth0

## Configuring NetworkManager to Ignore Certain Devices

默认情况NetworkManager管理所有网卡设备(除了lo)

- 可以通过配置unmanaged来忽略某些设备
- 从而可以通过脚本或者手动配置这些被忽略的设备的网络

nmcli device status中的unmanaged表示NetworkManager不管理该设备

	veth4115a7f        ethernet  unmanaged

设置enp0s31f6不受NetworkManager管理

	nmcli device set enp0s31f6 managed no

设置后状态如下

	enp0s31f6          ethernet  unmanaged               --

设置enp0s31f6受NetworkManager管理

	nmcli device set enp0s31f6 managed yes

设置后状态如下

	enp0s31f6          ethernet  unavailable             --

## 多ip配置

一张网口配置多个ip

	nmcli con add type ethernet con-name Myeth0 ifname enp0s31f6 ip4 192.168.2.101/24,192.168.10.2/24,192.168.0.2/24 gw4 192.168.2.1

碗口情况

	enp0s31f6        UP             192.168.2.101/24 192.168.10.2/24 192.168.0.2/24

路由情况

	default via 192.168.2.1 dev enp0s31f6 proto static metric 20100
	192.168.0.0/24 dev enp0s31f6 proto kernel scope link src 192.168.0.2 metric 100
	192.168.2.0/24 dev enp0s31f6 proto kernel scope link src 192.168.2.101 metric 100
	192.168.10.0/24 dev enp0s31f6 proto kernel scope link src 192.168.10.2 metric 100
