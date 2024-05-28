# Bluetooth usage

[Gentoo Wiki: Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)

[Gentoo Wiki: PulseAudio](https://wiki.gentoo.org/wiki/PulseAudio)

## Check hci driver info

查询系统中hci0使用的驱动是哪一个

	ls -l /sys/class/bluetooth/hci0/device/driver

下面显示是使用rtl btusb驱动

	/sys/class/bluetooth/hci0/device/driver -> ../../../../../../../bus/usb/drivers/rtk_btusb

下面显示使用内核自带的bt驱动

	/sys/class/bluetooth/hci0/device/driver -> ../../../../../../../bus/usb/drivers/btusb

## Changing Bluetooth Device Name

[changing bluetooth device name](https://www.baeldung.com/linux/changing-bluetooth-device-name)

using hciconfig -a command to find out the default name

    Name: 'BlueZ 5.72'

rename it to homepc

    sudo hciconfig hci0 name homepc
    Name: 'homepc'

## Send file from PC to bluetooth devices(net-wireless/bluez-tools)

    bt-obex -p 14:16:9E:49:EB:F6 /path/to/file.txt

## Config blue audio device(headset)

1. install pulseaudio with use bluetooth and daemon

	media-sound/pulseaudio bluetooth daemon

2. run the pulseaudio daemon system-wide(or config in dwm startup script)

	[~]$ pulseaudio
	E: [pulseaudio] upower.c: Get() failed: org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.UPower was not provided by any .service files

3. config bluz

install bluez with below use(deprecated for hciconfig)

	net-wireless/bluez cups debug deprecated test-programs

config bluetooth service

	rc-update add bluetooth default
	rc-service bluetooth start

config file for bluez(/etc/bluetooth/main.conf)

	[General]
	ControllerMode = bredr
	FastConnectable = true
	[Policy]
	AutoEnable=true

查看系统蓝牙控制器

	hciconfig -a

	hci0:   Type: Primary  Bus: USB
			BD Address: 04:7F:0E:65:C8:04  ACL MTU: 1021:9  SCO MTU: 255:4
			UP RUNNING PSCAN

如果第三行是DOWN可以通过下面来开启

	hciconfig hci0 up

使用rfkill查询蓝牙发射器的状态

	rfkill list bluetooth

### 使用交互模式连接蓝牙

进入交互模式

	$ bluetoothctl

列出控制器

	[bluetooth]# list
	Controller 04:7F:0E:65:C8:04 BlueZ 5.72 [default]

扫描设备

	[bluetooth]# scan on
	[bluetooth]# pair device_mac_address

### 使用命令行方式操作

    bluetoothctl devices
    bluetoothctl info device_mac_address
	bluetoothctl pair device_mac_address
    bluetoothctl connect device_mac_address

### FAQ

[hci0 command 0x1009 tx timeout, bluez can't find adapter](https://bugzilla.kernel.org/show_bug.cgi?id=64671)

[reset usb device](https://www.01signal.com/other/usb-device-stuck-reset/)

    [  114.890669] Bluetooth: hci0: command 0x1005 tx timeout
    [  114.890685] Bluetooth: hci0: Opcode 0x1005 failed: -110

below command can not fix my issue

    rmmod btusb
    modprobe btusb

try to reset the usb port using script below can fix it

    #!/usr/bin/python
    # pip install pyusb
    # Bus 001 Device 005: ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)

    from usb.core import find as finddev
    dev = finddev(idVendor=0x0a12, idProduct=0x0001)
    dev.reset()

using usbutils will be more convenient

    sudo usbreset 0a12:0001

## Usage of blueman(net-wireless/blueman)

    开机添加启动项 blueman-adapters

右键点击blueman托盘图标
    设置好Incoming Folder
    勾选Local Services,Accept files from trusted devices
    即可接收设备发来的文件

## Test with pybluez demo

install packages for compile pybluez and pyvenv(optional)

	sudo apt install -y libbluetooth-dev python3.10-venv

download pybluez source code

	git clone https://github.com/pybluez/pybluez

install pybluez in pyvenv

	pip3 install -e .

run server on ubuntu pc

	python3 srv.py

run client on rk3588 debian

	python3 cli.py

## Test with [bluetooth serial](https://wiki.archlinux.org/title/bluetooth)

Enable the config in kernel

	CONFIG_BT_RFCOMM=y
	CONFIG_BT_RFCOMM_TTY=y

将配对的远程设备绑定到本地的/dev/rfcomm0

	rfcomm bind rfcomm0 E4:0D:36:30:70:4F

查看绑定情况

	rfcomm show E4:0D:36:30:70:4F

在远程设备上运行服务端程序

	python3 srv.py

打开本地设备进行串口通信(同上面cli.py客户端)

	picocom /dev/rfcomm0 -b 115200

解除绑定

	rfcomm release E4:0D:36:30:70:4F

## About bluez

bluez中两个重要的目录CONFIGDIR和STORAGEDIR

CONFIGDIR是bluez daemon(bluetoothd)配置文件存放目录

	默认目录是 /etc/bluetooth/

STORAGEDIR是bluez bluetoothd存放每一个adapter和相关device信息的位置

	默认目录是 /var/lib/bluetooth/
	cat /var/lib/bluetooth/<adapter address>/<remote device address>/info

### 一些基本命令操作

bluetoothd是bluez的守护进程, 实现了如下profile

A2DP : Advanced Audio Distribution Profile
AVRCP : Audio/Video Remote Control Profile
GATT : Generic Attribute Profile
SDP : Service Discovery Protocol

并提供D-Bus services给外部程序使用(bluetooth.conf已被放置在/etc/dbus-1/system.d/ 目录下)

	在systemd中由 systemctl status bluetooth 启动
	或手动启动bluetoothd -n -d

- 如果需要能被其它设备搜索到,需要打开Inquiry Scan
- 如果需要被连接,需要开Page Scan

Inquiry Scan和Page Scan可以通过下面命令同时开启

	hciconfig hci0 piscan

	通过hciconfig  -a  查询输出的信息如下
        UP RUNNING PSCAN ISCAN

单独开iscan

	hciconfig hci0 iscan

单独开pscan

	hciconfig hci0 pscan

关闭pscan和iscan

	hciconfig hci0 noscan

### Test connection with bluez tool

L2CAP test command

	bluetoothctl connect E4:0D:36:30:70:4F
	l2ping E4:0D:36:30:70:4F

### 使用hcidump来调试(bluez-hcidump)

	hcidump -a

### 查询当前连接的设备和信号强度rssi(Received Signal Strength Indication)

关于信号强度,最理想是0dbm, 一般正常情况是-50dbm(值越大,信号越强)

	hcitool con

	Connections:
        > ACL E4:0D:36:30:70:4F handle 2 state 1 lm SLAVE AUTH ENCRYPT

	hcitool rssi E4:0D:36:30:70:4F

		RSSI return value: -59

	连接新设备后再查看连接情况

	bluetoothctl connect 14:16:9E:49:EB:F6
	hcitool con

	Connections:
		> ACL 14:16:9E:49:EB:F6 handle 5 state 1 lm SLAVE AUTH ENCRYPT
		> ACL E4:0D:36:30:70:4F handle 2 state 1 lm SLAVE AUTH ENCRYPT

	hcitool rssi 14:16:9E:49:EB:F6

		RSSI return value: -53 (比上面的信号更强一点)
