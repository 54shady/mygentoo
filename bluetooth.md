# Config bluez device

[Gentoo Wiki: Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)

[Gentoo Wiki: PulseAudio](https://wiki.gentoo.org/wiki/PulseAudio)

## Changing Bluetooth Device Name

[changing bluetooth device name](https://www.baeldung.com/linux/changing-bluetooth-device-name)

using hciconfig -a command to find out the default name

    Name: 'BlueZ 5.72'

rename it to homepc

    sudo hciconfig hci0 name homepc
    Name: 'homepc'

## Send file from PC to bluetooth devices(net-wireless/bluez-tools)

    bt-obex -p 14:16:9E:49:EB:F6 /path/to/file.txt

## config blue audio device(headset)

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

	[bluetooth]# scan
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
