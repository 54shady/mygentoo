## 打印机设置(HP DeskJet 1112)

[CUPS](https://wiki.archlinux.org/index.php/CUPS#Configuration)

[CUPS/Troubleshooting](https://wiki.archlinux.org/index.php/CUPS/Troubleshooting#USB_printers)

[CUPS/Printer-specific problems](https://wiki.archlinux.org/index.php/CUPS/Printer-specific_problems#HP)

USB打印机两种使用方式

- 通过内核usblp模块(经典方式, for simple printers, /dev/usb/usblp0)
- 通过libusb(for multi-function devices, printer/scanner)

USB打印机相关说明

- SANE会和CUPS用冲突,所以只能使用一个
- usblp和CUPS也会冲突

安装相关软件

	net-print/cups
	net-print/hplip

屏蔽内核自带打印机模块(/etc/modprobe.d/usblp.conf)

	blacklist usblp

添加当前用户到相关组(在/etc/cups/cups-files.conf中SystemGroup设置)

	gpasswd -a zeroway lpadmin

启动cups

	# /etc/init.d/cupsd start

使用gui工具配置打印机

	# hp-setup -u

打印文件

	$ hp-print
