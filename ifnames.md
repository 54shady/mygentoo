## 使用网卡名eth0,wlan0

systemd源码中对网卡命名规则注释

	 Two character prefixes based on the type of interface:
	   en — Ethernet
	   sl — serial line IP (slip)
	   wl — wlan
	   ww — wwan

	 Type of names:
	   b<number>                             — BCMA bus core number
	   c<bus_id>                             — CCW bus group name, without leading zeros [s390]
	   o<index>[d<dev_port>]                 — on-board device index number
	   s<slot>[f<function>][d<dev_port>]     — hotplug slot index number
	   x<MAC>                                — MAC address
	   [P<domain>]p<bus>s<slot>[f<function>][d<dev_port>]
											 — PCI geographical location
	   [P<domain>]p<bus>s<slot>[f<function>][u<port>][..][c<config>][i<interface>]
											 — USB port number chain

所以enp3s0对应的就是pci接口的以太网bus3,slot0

将网卡名固定成eth0,在内核启动参数添加如下内容(修改/boot/grub/grub.cfg)

	linux /vmlinuz ...   net.ifnames=0

或/etc/default/grub 中GRUB_CMDLINE_LINUX中内容都可以

	GRUB_CMDLINE_LINUX="net.ifnames=0"

