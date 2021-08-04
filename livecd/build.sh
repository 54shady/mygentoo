#!/bin/bash

LIVECD="/tmp/livecd"
LOCAL_ROOTFS=$1

copy_files_name=(
"bin"
"dev"
"etc"
"home"
"lib"
"lib32"
"lib64"
"media"
"mnt"
"opt"
"proc"
"root"
"run"
"sbin"
"sys"
"tmp"
"usr"
"var"
)

if [ ! -d "${LIVECD}/target/files/source"  ]; then
	mkdir -p ${LIVECD}/target/files/source
fi

#rsync --delete-after --archive --hard-links --quiet ${LIVECD}/source/boot ${LIVECD}/target/

#rsync --delete-after --archive --hard-links ${LIVECD}/source/ ${LIVECD}/target/files/source

#for d in ${copy_files_name[@]}
#do
#	rsync --archive --hard-links /$d ${LIVECD}/target/files/source/
#done

# use gentoo livecd iso file
rsync --progress --archive --hard-links $LOCAL_ROOTFS/ ${LIVECD}/target/files/source

cd ${LIVECD}/target/files

rm -f ${LIVECD}/target/livecd.squashfs
#cd $LOCAL_ROOTFS

# use current system rootfs
#mksquashfs / ${LIVECD}/target/livecd.squashfs -ef /home/zeroway/livecd/gentoo_livecd/exclude_file
mksquashfs source ${LIVECD}/target/livecd.squashfs -ef /home/zeroway/livecd/gentoo_livecd/exclude_file

cd ${LIVECD}

mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -hide-rr-moved -c boot.catalog -o ${LIVECD}/livecd.iso -x files ${LIVECD}/target
