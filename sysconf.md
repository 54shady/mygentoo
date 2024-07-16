# 系统软件配置

## [打印机设置HP DeskJet 1112](printer.md)

## [无线网络(wifi)配置](wifi.md)

## [使用nmcli配置有线网络](ethernet.md)

## [SSH client / server 配置](ssh_config.md)

## [管理多个ssh keys](sshkeys.md)

## 普通用户声卡设置(alsa)

设置i3wm后没有声音

执行aplay -l

	aplay: device_list:268: no soundcards found...

执行alsamixer

	cannot open mixer: No such file or directory

由于当前用户不是audio组中的用户,所以会找不到声卡

只需要将当前用户加到audio组中

	gpasswd -a zeroway audio
