#!/usr/bin/env bash

ROOTFS="$PWD/rootfs"

mount --bind /dev $ROOTFS/dev
mount --bind /run $ROOTFS/run

# update source list (optional)
#cp ./apt.conf $ROOTFS/etc/apt/
#cp ./sources.list $ROOTFS/etc/apt/
cp /etc/resolv.conf $ROOTFS/etc/
cp stage2.sh $ROOTFS/root/

chroot $ROOTFS /root/stage2.sh
