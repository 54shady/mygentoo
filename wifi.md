# 无线网络(wifi)配置

Gentoo中有多种方式配置网络(每种之间都是冲突的,所以只能选择一种)

- wpa_supplicant
- nmcli/nmtui
- NetworkManager

## 查询系统中wlan0使用的驱动是哪一个

	ls -l /sys/class/net/wlan0/device/driver

	/sys/class/net/wlan0/device/driver -> ../../../../../../../bus/usb/drivers/rtl88x2cu

	ls -l /sys/class/net/usb0/device/driver (4G网络模块)

	/sys/class/net/usb0/device/driver -> ../../../../../../../bus/usb/drivers/GobiNet

## 使用wpa_supplicant配置方法

只需要在rc-update里关闭NetworkManager(如果默认有启动的话)

	/etc/init.d/NetworkManager stop

假设无线网卡名为wlan0

	cd /etc/init.d
	ln -s net.lo net.wlan0

添加如下代码到/etc/con.d/net 中才能自动获取IP地址

	modules_wlan0="wpa_supplicant"
	config_wlan0="dhcp"

添加如下配置到/etc/conf.d/wpa_supplicant 中

	wpa_supplicant_args="-B -M -c/etc/wpa_supplicant/wpa_supplicant.conf"

设置权限(限制查看wifi密码)

	chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

配置/etc/wpa_supplicant/wpa_supplicant.conf 文件

	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=users
	update_config=1
	network={
		ssid="ap_ssid_name"
		bssid=94:d9:b3:a4:01:de
		psk="aka_wifi_passwd"
	}

### 使用wpa_cli来连接

    wpa_cli add_network
    wpa_cli set_network 0 ssid "ap_ssid_name"
    wpa_cli set_network 0 psk "aka_wifi_passwd"
    wpa_cli enable_network 0
    wpa_cli select_network 0
    wpa_cli save_config

开机启动wpa_supplicant

	rc-update add wpa_supplicant default

手动开启和关闭wpa_supplicant

	/etc/init.d/wpa_supplicant <start | stop | restart>
    或
    rc-service wpa_supplicant <start | stop | restart>

## 使用NetworkManager方法

查询当前wifi热点

	nmcli device wifi list

### 连接ssid+password的wifi热点,并取名为MyWifiConnected

	sudo /etc/init.d/NetworkManager start
	sudo nmcli device wifi connect <SSID> password <PASSWD> name MyWifiConnected

显示连接的ap或热点的秘密并显示二维码

	nmcli device wifi show-password

显示当前连接情况

	nmcli connection show
	nmcli connection up MyWifiConnected
	nmcli connection down MyWifiConnected

删除这个连接

	nmcli connection delete MyWifiConnected

### 连接需要用户名和密码的ap[(参考连接)](https://unix.stackexchange.com/questions/145366/how-to-connect-to-an-802-1x-wireless-network-via-nmcli)

先设置对应的信息

	export WIFI_USER_NAME="your-user-name"
	export WIFI_PASSWORD="your-password"
	export WIFI_CON_ID='your-connection-one'
	export WIFI_SSID='your-ap-ssid'

建立连接(会在/etc/NetworkManager/system-connections目录下生成对应的配置文件)

	nmcli connection add \
		type wifi \
		con-name $WIFI_CON_ID \
		ifname wlan0 \
		ssid $WIFI_SSID \
		-- \
		wifi-sec.key-mgmt wpa-eap \
		802-1x.eap peap \
		802-1x.phase2-auth mschapv2 \
		802-1x.identity $WIFI_USER_NAME \
		802-1x.password $WIFI_PASSWORD

启动/关闭连接

    nmcli connection up id $WIFI_CON_ID
    nmcli connection down id $WIFI_CON_ID

删除连接

    nmcli connection delete id $WIFI_CON_ID

## 共享wifi网络给有线网络

主机A通过wifi能够上网(主机B没有无线网卡,想通过有线连接到主机A后也能上网)

通过在A上配置路由转发将eth0上的数据转发到wlan0从而让B能使用有线上网

	+---------------------+
	|     A       		  |
	|              wlan0  |-----------> Internet
	|                ^    |
	|                |    |
	|                |    |
	| 192.168.2.101 eth0  +--<--+
	+---------------------+     |
						        |
	+----------------------+    ^
	|     B                |    |
	|                      |    |
	| 192.168.2.102  eth0  +->--+
	+----------------------+

在A主机上设置如下

	echo 1 > /proc/sys/net/ipv4/ip_forward
	iptables -F
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

在B主机上设置如下路由

	route add -net 0.0.0.0/0 gw <主机A的eth0 ip>

比如这里如下

	route add -net 0.0.0.0/0 gw 192.168.2.101

此时在B上就能通过eth0来上网了

	ping 8.8.8.8 -I eth0

## 使用nmcli创建热点

create a hotspot

	nmcli con add type wifi ifname wlp0s20f3 \
		con-name myhotspot autoconnect yes ssid myhotspot \
		802-11-wireless.mode ap 802-11-wireless.band bg \
		ipv4.method shared wifi-sec.key-mgmt wpa-psk \
		802-11-wireless-security.pmf 1 \
		wifi-sec.psk "12345678"
	nmcli con up myhotspot
	nmcli device wifi show-password
