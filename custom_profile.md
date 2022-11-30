# Create custom profiles

[Gentoo Profiles](https://wiki.gentoo.org/wiki/Profile_(Portage))

创建一个repo配置文件内容如下(/etc/portage/repos.conf/local.conf)

	cat << EOF > /etc/portage/repos.conf/local.conf
	[local]
	# 'eselect repository' default location
	location = /var/db/repos/local
	EOF

设置repo名(/var/db/repos/local/profiles/repo_name)

	mkdir -p /var/db/repos/local/{profiles,metadata}
	echo "local" > /var/db/repos/local/profiles/repo_name

设置layout(/var/db/repos/local/metadata/layout.conf)

	cat << EOF > /var/db/repos/local/metadata/layout.conf
	# Slave repository rather than stand-alone
	masters = gentoo
	profile-formats = portage-2
	EOF

假设x11-terms/st在当前profile下是没有设置如下use的,现在想在新的profile中默认配置这个use

	equery u x11-terms/st
	[ Legend : U - final flag setting for installation]
	[        : I - package is installed with flag     ]
	[ Colors : set, unset                             ]
	 * Found these USE flags for x11-terms/st-9999:
	 U I
	 - - savedconfig : Use this to restore your config from
					   /etc/portage/savedconfig ${CATEGORY}/${PN}. Make sure
					   your USE flags allow for appropriate dependencies

配置需要修改的use

	cd /var/db/repos/local/profiles
	mkdir savedconfig && echo 7 > savedconfig/eapi
	echo "x11-terms/st savedconfig" > savedconfig/package.use

创建custom目录

	profile_name=custom
	mkdir $profile_name && echo 7 >$profile_name/eapi
	cat << EOF > $profile_name/parent
	gentoo:default/linux/amd64/17.0
	../savedconfig
	EOF

创建profile.desc文件

	echo `portageq envvar ARCH` $profile_name dev >>profiles.desc

现在就可以查看到自己创建的profile了

	eselect profile list

	Available profile symlink targets:
	  ...
	  [88]  local:custom (dev)

选择使用这个自定义的profile

	eselect profile set 88

再次查看之前配置的软件use情况和之前不一样了

	equery u x11-terms/st
	[ Legend : U - final flag setting for installation]
	[        : I - package is installed with flag     ]
	[ Colors : set, unset                             ]
	 * Found these USE flags for x11-terms/st-9999:
	 U I
	 + - savedconfig : Use this to restore your config from
					   /etc/portage/savedconfig ${CATEGORY}/${PN}. Make sure
					   your USE flags allow f`
