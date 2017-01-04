#!/bin/bash

LIVECD="/home/zeroway/livecd"

copy_files_name=(
"proc"
"dev"
"sys"
"usr/portage/distfiles"
)

make_directory()
{
	for d in ${copy_files_name[@]}
	do
		if [ -d $d ]
		then
			echo "exist $d"
		else
			mkdir -p $d
		fi
	done
}

bind_directory()
{
	# mount the directory
	for d in ${copy_files_name[@]}
	do
		mount --bind /$d $d
	done
}

unbind_directory()
{
	cd ${LIVECD}/source
	# unmount the directory
	for d in ${copy_files_name[@]}
	do
		umount $d
	done
}

# Usage
# bind bind the directory
# bind -r unbind the directory
if [ "$1" = "-r" ]
then
	cd ${LIVECD}/source
	unbind_directory
else
	cd ${LIVECD}/source
	make_directory
	bind_directory
fi
