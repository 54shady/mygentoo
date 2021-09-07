#!/bin/bash

UTIL_PATH=$PWD

echo "Start install gentoo;-)"
read -p "Yes/No " TMP

grep "/mnt/gentoo" /proc/mounts
if [ $? -eq 0 ]
then
	umount /mnt/gentoo
	rm -rf /mnt/gentoo
	mkdir /mnt/gentoo
fi

echo "Input Target Disk"
read devx
echo $devx
if [ $TMP == y ]; then
	echo "Start Installation process"
	$UTIL_PATH/autopartx.sh $devx
else
	echo "No"
fi

mount ${devx}2 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount ${devx}1 /mnt/gentoo/boot

echo "Input stage3 tar ball"
read stage

tar jxvf $stage -C /mnt/gentoo/

mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

cp deploy.sh /mnt/gentoo/root/deploy.sh
chmod +x /mnt/gentoo/root/deploy.sh
HOST_NAME="newdeploy"
chroot /mnt/gentoo /root/deploy.sh $HOST_NAME
