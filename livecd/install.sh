#!/bin/bash

# livecd rootfs mount point
LIVECD_ROOTFS="/mnt/livecd"

# partitions
BOOT_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/sda3"

# mount points
ROOT_MOUNTPOINT="/mnt/gentoo"
BOOT_MOUNTPOINT="/mnt/gentoo/boot"

# mount the filesystem
mount $ROOT_PARTITION $ROOT_MOUNTPOINT
mkdir $BOOT_MOUNTPOINT
mount $BOOT_PARTITION $BOOT_MOUNTPOINT

# copy the dvd to filesystem
eval `grep '^ROOT_' /usr/share/genkernel/defaults/initrd.defaults`
cd $LIVECD_ROOTFS
cp -avx $LIVECD_ROOTFS/$ROOT_LINKS /mnt/gentoo
cp -avx $LIVECD_ROOTFS/$ROOT_TREES /mnt/gentoo

tar cvf - -C $LIVECD_ROOTFS/dev/ . | tar xvf - -C /mnt/gentoo/dev/
tar cvf - -C $LIVECD_ROOTFS/etc/ . | tar xvf - -C /mnt/gentoo/etc/

# config the filesystem
mount -t proc none $ROOT_MOUNTPOINT/proc
mount -o bind $LIVECD_ROOTFS/dev $ROOT_MOUNTPOINT/dev

# chroot into the filesystem
chroot $ROOT_MOUNTPOINT /bin/bash
env-update && source /etc/profile
rm -rf null zero console
mknod null c 1 3
mknod console c 5 1
mknod zero c 1 5
chmod 666 null
chmod 600 console
chmod 666 zero

rc-update del autoconfig default
rc-update del fixinittab boot

# config fstab

# copy kernel and initramfs to filesystem
cp /dev/cdrom/boot/* /boot/
