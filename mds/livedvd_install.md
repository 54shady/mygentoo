# Quick Install Gentoo With LiveDVD

## LiveDVD

livedvd-amd64-multilib-20160704.iso

## Partition Prepare

UEFI boot mode partition as below(/etc/fstab)

	/dev/sda1       /boot   vfat    defaults,noatime        0       2
	/dev/sda2       none    swap    sw      0       0
	/dev/sda3       /       ext4    noatime 0       1

Format partition for UEFI(The ESP must be a FAT variant)

	mkfs.fat -F 32 /dev/sda1
	mkswap /dev/sda2
	mkfs.ext4 /dev/sda3

Mount partition

	mount /dev/sda3 /mnt/gentoo
	mkdir /mnt/gentoo/boot
	mount /dev/sda1 /mnt/gentoo/boot

## PreInstall Configuration

Copy core files from livedvd

	cp -apfv /mnt/livecd/* /mnt/gentoo/

Mount something

	mount -t proc proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev

## Chroot to the real world

Do chroot

	chroot /mnt/gentoo /bin/bash
	source /etc/profile

Build kernel and ramdisk

	genkernel all

## Install grub

Grub with UEFI support

	echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
	emerge sys-boot/grub:2

	grub-install --target=x86_64-efi --efi-directory=/boot --removable
	grub-mkconfig -o /boot/grub/grub.cfg

Grub Legacy BIOS support

	grub-install /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg

## References Documentation

[Ref doc1](http://blog.chinaunix.net/uid-620765-id-4065478.html)

[Ref doc2](http://blog.csdn.net/connect_/article/details/46226823)
