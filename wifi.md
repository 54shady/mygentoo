## 无线网络(wifi)配置

Gentoo中有多种方式配置网络

- wpa_supplicant
- nmcli/nmtui
- NetworkManager

其中每种之前都是冲突的

所以只能选择一种

### 使用wpa_supplicant配置方法

只需要在rc-update里关闭NetworkManager(如果默认有启动的话)

	/etc/init.d/NetworkManager stop

假设无线网卡名为wlan0

	cd /etc/init.d
	ln -s net.lo net.wlan0

添加如下代码到/etc/con.d/net中,才能自动获取IP地址

	modules_wlan0="wpa_supplicant"
	config_wlan0="dhcp"

添加如下配置到/etc/conf.d/wpa_supplicant中

	wpa_supplicant_args="-B -M -c/etc/wpa_supplicant/wpa_supplicant.conf"

设置权限(限制查看wifi密码)

	chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

配置/etc/wpa_supplicant/wpa_supplicant.conf文件

	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=users
	update_config=1
	network={
		ssid="ap_ssid_name"
		bssid=94:d9:b3:a4:01:de
		psk="aka_wifi_passwd"
	}

开机启动wpa_supplicant

	rc-update add wpa_supplicant default

手动开启和关闭wpa_supplicant

	/etc/init.d/wpa_supplicant <start | stop | restart>

### 使用NetworkManager方法

通过下面命令来连接wifi(热点)

	sudo /etc/init.d/NetworkManager start
	sudo nmcli device wifi connect <SSID> password <PASSWD>
