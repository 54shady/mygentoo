# Quick Install Gentoo (on DELL 3550) with UEFI only

## Partition Prepare

Partition table as below

	/dev/sda1	/boot
	/dev/sda2	swap
	/dev/sda3	/


Format partition(Boot partition must be fat)

	mkfs.fat -F 32 /dev/sda1
	mkfs.ext4 /dev/sda3

Mount partition

	mount /dev/sda3 /mnt/gentoo
	mount /dev/sda1 /mnt/gentoo/boot

## PreInstall Configuration

Copy core files

	eval `grep '^ROOT_' /usr/share/genkernel/defaults/initrd.defaults`
	cp -apfv /mnt/livecd/* /mnt/gentoo/
	cp /etc/passwd /etc/group /mnt/gentoo/etc
	mkdir /mnt/gentoo/proc /mnt/gentoo/dev
	cd /mnt/gentoo/dev
	mknod -m 660 console c 5 1
	mknod -m 660 null c 1 3

Mount something

	mount -t proc proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev

## Chroot to the real world

Do chroot

	chroot /mnt/gentoo /bin/bash
	env-update
	source /etc/profile

Build kernel and ramdisk

	emerge -v sys-kernel/gentoo-sources
	emerge -v sys-kernel/genkernel
	genkernel all

## Install grub2

UEFI support config

	echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
	emerge sys-boot/grub:2

	grub2-install --target=x86_64-efi --efi-directory=/boot --removable
	grub2-mkconfig -o /boot/grub/grub.cfg

## References Documentation

[Ref doc1](http://blog.chinaunix.net/uid-620765-id-4065478.html)

[Ref doc2](http://blog.csdn.net/connect_/article/details/46226823)
