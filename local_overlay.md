local overlay的用法,官网上也有详细说明,这里只是个人积累
用的时候需要修改源码后再安装软件,这里就可以用local overlay的方法来操作

比如:
默认grep出来的结果是用":"分割的
我想把这个":"分割号改成"+"号,以便可以用vi直接打开相应的文件和对应的行

1. 创建一个本地的overlay,我这里取名叫mobzoverlay
```shell
root # mkdir -p /usr/local/portage/{metadata,profiles}
root # echo 'mobzoverlay' > /usr/local/portage/profiles/repo_name
root # echo 'masters = gentoo' > /usr/local/portage/metadata/layout.conf
root # chown -R portage:portage /usr/local/portage
```

cat /etc/portage/repos.conf/local.conf
[mobzoverlay]
location = /usr/local/portage
masters = gentoo
auto-sync = no

```shell
root # mkdir -p /usr/local/portage/sys-apps/grep
root # cp /usr/portage/sys-apps/grep/grep-2.21-r1.ebuild  /usr/local/portage/sys-apps/grep/
root # chown -R portage:portage /usr/local/portage
root # pushd /usr/local/portage/sys-apps/grep
root # repoman manifest
root # popd 
```
注意：每次修改了ebuild文件后就需要重新生成manifest文件

其中我在原有的ebuild文件里添加下面第二行打mygrep.patch的代码
epatch "${DISTDIR}/${P}-heap_buffer_overrun.patch"
epatch -p1 -R "/usr/portage/distfiles/mygrep.patch"

其中patch文件制作可以用git也可以直接用diff
git diff commit1 commit2 > mygrep.patch
diff -aurNp dir1 dir2 > mygrep.patch

另外：
	安装软件的时候可以指定用哪个repo或是overlay
	安装系统的portage里的grep:
		emerge grep::gentoo
	安装本地mobzoverlay里的grep:
		emerge grep::mobzoverlay
