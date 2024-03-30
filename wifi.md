# 无线网络(wifi)配置

Gentoo中有多种方式配置网络(每种之间都是冲突的,所以只能选择一种)

- wpa_supplicant
- nmcli/nmtui
- NetworkManager

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
    wpa_clit set_network 0 ssid "ap_ssid_name"
    wpa_clit set_network 0 psk "aka_wifi_passwd"
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

### 连接ssid+password的wifi热点

	sudo /etc/init.d/NetworkManager start
	sudo nmcli device wifi connect <SSID> password <PASSWD>

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
