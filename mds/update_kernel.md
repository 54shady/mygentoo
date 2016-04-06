```shell
1. 下载最新内核代码,这里用的是4.4.4的内核代码:
echo ">=sys-kernel/gentoo-sources-4.4.4 ~amd64" >>  /etc/portage/package.accept_keywords

emerge -v  sys-kernel/gentoo-sources

2. 选择相应的代码:
查看系统里内核代码
eselect kernel list

选择需要的代码
eselect kernel set 2

/usr/src/linux这个软链接就会指向相应的代码

3. 编译:
genkernel all

4. 更新grub
grub2-mkconfig -o /boot/grub/grub.cfg
```
