#!/usr/bin/env bash

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

#cat > /etc/resolv.conf << EOF
#nameserver a.b.c.d
#EOF

echo "ubuntu-fs-live" > /etc/hostname
apt-get update

# Install systemd
apt-get install -y systemd

# install pkgs
apt-get install -y vim

# Clean up
apt autoremove && apt autoclean && apt clean

rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0
exit
