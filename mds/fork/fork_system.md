# Fork linux system and deploy

## prepare the stage4 tarball

using the [backup minial script](backup_mini.sh)

## prepare the partiton

partition the disk using [auto_parted](auto_parted.sh)

	/dev/sda1   boot
	/dev/sda2   /
	/dev/sda3   swap
	/dev/sda4   home

format the each partition

	mkfs.fat -F 32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkswap /dev/sda3
	mkfs.ext4 /dev/sda4

mount the root and boot

	mount /dev/sda2 /mnt
	mount /dev/sda1 /mnt/boot

## deploy the stage4

	tar jxvf stage4.tar.bz2 -C /mnt

## prepare the local disk

using the [chmount script](chmount.sh)

	mount -t proc proc /mnt/proc
	mount --rbind /sys /mnt/sys
	mount --make-rslave /mnt/sys
	mount --rbind /dev /mnt/dev
	mount --make-rslave /mnt/dev
	chroot /mnt /bin/bash

## update the fstab

using [fstab mini](fstab_mini)

## instal grub

install the grub using the command below

	grub-install --target=x86_64-efi --efi-directory=/boot --removable
	grub-mkconfig -o /boot/grub/grub.cfg
