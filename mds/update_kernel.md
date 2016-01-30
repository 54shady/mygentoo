```shell
在/etc/portage/package.mask/mask中屏蔽掉高版本的内核
默认安装高版本内核显示驱动不如4.1.15
>sys-kernel/gentoo-sources-4.1.15-r1

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
