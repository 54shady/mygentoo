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
rsync --archive --hard-links $LIVECD_ROOTFS/$ROOT_LINKS $ROOT_MOUNTPOINT/
rsync --archive --hard-links $LIVECD_ROOTFS/$ROOT_TREES $ROOT_MOUNTPOINT/

tar cvf - -C $LIVECD_ROOTFS/dev/ . | tar xvf - -C /mnt/gentoo/dev/
tar cvf - -C $LIVECD_ROOTFS/etc/ . | tar xvf - -C /mnt/gentoo/etc/

# config the filesystem
mkdir -p $ROOT_MOUNTPOINT/proc
mkdir -p $ROOT_MOUNTPOINT/dev
mount -t proc none $ROOT_MOUNTPOINT/proc
mount -o bind $LIVECD_ROOTFS/dev $ROOT_MOUNTPOINT/dev

# chroot into the filesystem, install stage1 done
chroot $ROOT_MOUNTPOINT /bin/bash
