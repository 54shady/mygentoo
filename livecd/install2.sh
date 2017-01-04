#!/bin/bash

# install stage 2 start
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
