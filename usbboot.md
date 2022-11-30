## USB启动盘

### 单一系统启动盘

烧写镜像(单一系统启动)

	dd bs=4M if=/path/to/gentoo.iso of=/dev/sdx status=progress oflag=sync

使用wget或curl从网络下载文件并烧写

	curl http://server/gentoo.iso | sudo dd of=/dev/sdx bs=4M oflag=sync status=progress
	wget -q -O - http://server/gentoo.iso | sudo dd of=/dev/sdx bs=4M oflag=sync status=progress

可以使用虚拟机来测试是否刻录成功

	sudo qemu-system-x86_64 -enable-kvm -m 1G -vga std \
		-drive file=/dev/sdx,readonly=on,cache=none,format=raw,if=virtio

### 多系统启动盘(支持legacy和uefi)

使用multibootusb制作

	git clone https://github.com/aguslr/multibootusb
	./makeUSB.sh -b -e /dev/sdX

将可引导的iso文件拷贝到/dev/sdX3下的isos目录里

使用虚拟机测试

	sudo qemu-system-x86_64 -smp 4 -enable-kvm -rtc base=localtime -m 2G -vga std -drive file=/dev/sdX,readonly,cache=none,format=raw,if=virtio
