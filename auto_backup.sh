#!/bin/bash

#set -x

WORLD="/var/lib/portage/world"
MAKE_CONFIG="/etc/portage/make.conf"
PACKAGE_USE="/etc/portage/package.use/use"
PACKAGE_MASK="/etc/portage/package.mask/mask"
PACKAGE_UNMASK="/etc/portage/package.unmask"
PACKAGE_ACCEPT_KEYWORDS="/etc/portage/package.accept_keywords/accept_keywords"
REPOS_GENTOO="/etc/portage/repos.conf/gentoo"
REPOS_LOCAL="/etc/portage/repos.conf/local.conf"
RSYNC_EXCLUDES="/etc/portage/rsync_excludes"
PACKAGE_LICENSE="/etc/portage/package.license/license"
ANDROID_RULES="/etc/udev/rules.d/51-android.rules"

# 把需要备份的文件放在这个数组中
copy_files_name=(
$WORLD
$MAKE_CONFIG
$PACKAGE_USE
$PACKAGE_MASK
$PACKAGE_UNMASK
$PACKAGE_ACCEPT_KEYWORDS
$REPOS_GENTOO
$REPOS_LOCAL
$RSYNC_EXCLUDES
$PACKAGE_LICENSE
$ANDROID_RULES
)

# 遍历数组里的文件进行复制
for file in ${copy_files_name[@]}
do
	# 先判断源文件是否存在,存在才执行备份操作
	if [ -f $file ]; then
		dst_dir_tmp=${file%/*}
		dst_dir=${dst_dir_tmp#/*}
		if [ ! -d ${dst_dir} ]; then
			mkdir -p ${dst_dir}
		fi

		# 备份相应目录的文件
		cp $file ${file#*/}
	fi
done

# backup the localoverlay
cp -rvfd /usr/local/portage usr/local/

echo "All things have get done."
