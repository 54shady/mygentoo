#!/usr/bin/env bash

ROOTFS="$PWD/rootfs"

umount $ROOTFS/run
umount $ROOTFS/dev

tar -cvJf rootfs.tar.xz \
	--exclude=usr/include/* \
	--exclude=var/lib/apt/lists/* \
	--exclude=var/lib/dpkg/info/* \
	--exclude=usr/share/doc/* \
	--exclude=usr/share/man/* \
	-C $ROOTFS/ .
