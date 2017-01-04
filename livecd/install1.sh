#!/bin/bash
set -x

copy_files_name=(
"bin"
"etc"
"home"
"lib"
"lib32"
"lib64"
"mnt"
"opt"
"root"
"sbin"
"usr"
)

# stage 2 script
INSTALL_STAGE2_SCRIPTS="install2.sh"

# fstab
TARGET_FSTAB="fstab"

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
for d in ${copy_files_name[@]}
do
	rsync --progress --archive --hard-links $LIVECD_ROOTFS/$d $ROOT_MOUNTPOINT/
done
#eval `grep '^ROOT_' /usr/share/genkernel/defaults/initrd.defaults`
##cd $LIVECD_ROOTFS
#rsync --archive --hard-links $LIVECD_ROOTFS/$ROOT_LINKS $ROOT_MOUNTPOINT/
#rsync --archive --hard-links $LIVECD_ROOTFS/$ROOT_TREES $ROOT_MOUNTPOINT/

tar cvf - -C $LIVECD_ROOTFS/dev/ . | tar xvf - -C /mnt/gentoo/dev/
tar cvf - -C $LIVECD_ROOTFS/etc/ . | tar xvf - -C /mnt/gentoo/etc/

# config the filesystem
mkdir -p $ROOT_MOUNTPOINT/proc
mkdir -p $ROOT_MOUNTPOINT/dev
mkdir -p $ROOT_MOUNTPOINT/sys
mount -t proc proc $ROOT_MOUNTPOINT/proc
mount --rbind /sys $ROOT_MOUNTPOINT/sys
mount --make-rslave $ROOT_MOUNTPOINT/sys
mount --rbind /dev $ROOT_MOUNTPOINT/dev
mount --make-rslave $ROOT_MOUNTPOINT/dev

# copy kernel and initramfs to filesystem
cp /mnt/cdrom/boot/kernel* $BOOT_MOUNTPOINT/
cp /mnt/cdrom/boot/initr* $BOOT_MOUNTPOINT/
cp /mnt/cdrom/boot/vmlinuz $BOOT_MOUNTPOINT/

cp $INSTALL_STAGE2_SCRIPTS $ROOT_MOUNTPOINT/
cp $TARGET_FSTAB $ROOT_MOUNTPOINT/etc/

# chroot into the filesystem, install stage1 done
chroot $ROOT_MOUNTPOINT /bin/bash
