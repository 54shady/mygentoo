## 使用UEFI模式启动的电脑安装GENTOO

下面只说明差异部分

假设/dev/sda1就是EFI分区,那就让gentoo使用这个分区

使用刻录ubuntu14.04到u盘,这里借用ubuntu的刻录盘来进入到UEFI模式

[参考链接](http://jingyan.baidu.com/article/a378c960630e61b329283045.html)

使用UEFI模式启动,需要关掉secure boot功能

分区和挂载点:

sda4 ==> /home

sda5 ==> /

sda6 ==> swap

	mkfs.ext4 /dev/sda4
	mkfs.ext4 /dev/sda5
	mkswap /dev/sda6
	swapon  /dev/sda6

	mkdir /mnt/gentoo
	mount /dev/sda5 /mnt/gentoo/
	mkdir /mnt/gentoo/boot/efi -p

挂载EFI分区

	mount /dev/sda1 /mnt/gentoo/boot/efi

下面到操作要保证能成功的前提是启动到时候是UEFI模式启动的

安装grub支持EFI,这里指定的EFI目录就是挂载到sda1

	echo GRUB_PLATFORMS="efi-64" >> /etc/portage/make.conf
	emerge sys-boot/grub:2
	grub-install --target=x86_64-efi --efi-directory=/boot --removable
	grub-mkconfig -o /boot/grub/grub.cfg

