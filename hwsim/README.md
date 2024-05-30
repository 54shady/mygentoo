# mac80211 hwsim

编译内核对应的模块

	CONFIG_MAC80211_HWSIM=m

[emulating wlan in liux via mac80211 hwsim](https://linuxembedded.fr/2021/01/emulating-wlan-in-linux-part-ii-mac80211hwsim)

加载驱动,默认会生成两个设备,假设是wlan2, wlan3(这些wlan在底层都是联通的)

	insmod mac80211_hwsim.ko

下面命令列出所有wifi和蓝牙的phy

	rfkill list

比如查看phy1的信息

	iw phy phy1 info

## 下面将wlan2配置成AP热点，让wlan3连接到该AP

先清wlan2 ip(默认wlan2 是没有ip)

	ifconfig wlan2 0.0.0.0 down

用下面的配置文件hostapd.conf启动hostapd

	interface=wlan2
	driver=nl80211
	ieee80211n=1
	hw_mode=g
	channel=6
	ssid=myssid
	wpa=2
	wpa_passphrase=a12345678A
	wpa_key_mgmt=WPA-PSK
	rsn_pairwise=CCMP TKIP
	wpa_pairwise=TKIP CCMP

在wlan2上启动hostapd

	hostapd hostapd.conf

在wlan2上用下面的配置udhcpd.conf启动udhcpd

	start 192.168.75.2
	end 192.168.75.254
	interface wlan2
	max_leases 234
	opt router 192.168.75.1

配置wlan2 ip 后启动udhcpd

	ifconfig wlan2 192.168.75.1/24 up
	touch /var/lib/misc/udhcpd.leases
	udhcpd -f udhcpd.conf

使用下面配置文件wpa_supplicant.conf启动wpa

	ctrl_interface=/var/run/wpa_supplicant
	network={
		ssid="myssid"
		psk="a12345678A"
	}

如果wlan3有ip,要先清掉

	ifconfig wlan3 0.0.0.0 down

启动wpa_supplicant命令(使用的wlan3连接wlan2的热点)

	wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant.conf -i wlan3

使用dhcp客户端获取wlan3的ip

	dhclient wlan3

## 配合network namespace来测试(将wlan3隔离到netnamespace ns1中)

在新终端执行下面命令(会进入到namespace shell, 不要退出)

设置namespace名

	netns=ns1

将wlan3添加到namespace

	ip netns add "$netns"
	ip netns exec $netns /bin/bash
	echo $$ > /var/run/ns1.pid

在原终端执行将wlan3添加到namespace

	PID=$(cat /var/run/ns1.pid)
	iw phy phy2 set netns $PID

在进入到namespace的终端中执行(能ping通AP)

	wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant.conf -i wlan3
	dhclient wlan3

	ping 192.168.75.1 -I wlan3
