#!/bin/bash

UTIL_PATH=$PWD
CHROOT="/mnt/gentoo"
HOST_NAME="Gentoo"

grep "/mnt/gentoo" /proc/mounts
[ $? -eq 0 ] && { umount $CHROOT; rm -rf $CHROOT; mkdir $CHROOT; }

read -p "Install gentoo;-) [Y]es/[N]o: " TMP
[ $TMP == y ] && \
	{ read -p "Target Disk " devx; $UTIL_PATH/autopartx.sh $devx; } || \
	{ echo "Abort installation"; exit; }

mount ${devx}2 $CHROOT
mkdir $CHROOT/boot
mount ${devx}1 $CHROOT/boot

read -p "Input Stage3 tarball: " stage
tar jxvf $stage -C $CHROOT/

mount -t proc /proc $CHROOT/proc
mount --rbind /sys $CHROOT/sys
mount --make-rslave $CHROOT/sys
mount --rbind /dev $CHROOT/dev
mount --make-rslave $CHROOT/dev

# update fstab
cp fstab $CHROOT/etc/
diskname=${devx##*/}
sed -i -e "s/bootp/${diskname}1/" \
	-e "s/rootp/${diskname}2/" \
	-e "s/homep/${diskname}4/" \
	-e "s/swapp/${diskname}3/" \
	$CHROOT/etc/fstab

cp deploy.sh $CHROOT/root/deploy.sh
chmod +x $CHROOT/root/deploy.sh
chroot $CHROOT /root/deploy.sh $HOST_NAME
