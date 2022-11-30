# USBView

软件安装

	sudo emerge -v app-admin/usbview

因为该软件需要访问/sys/kernel/debug/usb目录需要root权限

但是使用root用户会有下面的错误

	(usbview:4377): Gtk-WARNING **: cannot open display: :0

需要在非root用户下执行

	$ xhost local:root

原因是root用户没有加入到zeroway访问X server的权限里

	$ sudo usbview 就可以执行了
