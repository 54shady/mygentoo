# mygentoo

All the stuffs about my gentoo linux

copy all the file to the same directory

etc is /etc

user is /home/your_local_user_name or /root

usr is /usr

var is /var

## Gentoo使用

[Linux开发环境搭建](./mds/linux_dev.md)

[LocalOverlay使用方法](./mds/local_overlay.md)

[自己写ebuild](./mds/my_ebuild.md)

[更新内核的方法](./mds/update_kernel.md)

## terminator solarized

配色设置方法(https://github.com/ghuntley/terminator-solarized.git)

	git clone https://github.com/ghuntley/terminator-solarized.git
	cd terminator-solarized
	mkdir -p ~/.config/terminator/
	cp config ~/.config/terminator

## fcitx输入法设置

	export XMODIFIERS=@im=fcitx
	export XIM=fcitx
	export XIM_PROGRAM=fcitx
	export GTK_IM_MODULE=fcitx
	export QT_IM_MODULE=fcitx
