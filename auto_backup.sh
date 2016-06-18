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
)

# 遍历数组里的文件进行复制
for file in ${copy_files_name[@]}
do
	# echo $file 'exist, ready to backup...'
	# file exists and is a regular file
	if [ -f $file ]; then
		# 先创建一个空的对应目录的文件
		# 从左往右取第一个子串('/')后面的字符串
		# 即去掉最前面的'/'
		touch ${file#*/}

		# 备份
		cp $file ${file#*/}

	#	echo "backup to" ${file#*/} "done!!"
	fi
done

echo "All things have get done."
