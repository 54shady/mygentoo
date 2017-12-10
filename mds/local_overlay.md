```shell
local overlay的用法,官网上也有详细说明,这里只是个人积累
用的时候需要修改源码后再安装软件,这里就可以用local overlay的方法来操作

例子1:
默认grep出来的结果是用":"分割的
我想把这个":"分割号改成"+"号,以便可以用vi直接打开相应的文件和对应的行

1. 创建一个本地的overlay,我这里取名叫mobzoverlay
root # mkdir -p /usr/local/portage/{metadata,profiles}
root # echo 'mobzoverlay' > /usr/local/portage/profiles/repo_name
root # echo 'masters = gentoo' > /usr/local/portage/metadata/layout.conf
root # chown -R portage:portage /usr/local/portage

cat /etc/portage/repos.conf/local.conf
[mobzoverlay]
location = /usr/local/portage
masters = gentoo
auto-sync = no

root # mkdir -p /usr/local/portage/sys-apps/grep
root # cp /usr/portage/sys-apps/grep/grep-2.21-r1.ebuild  /usr/local/portage/sys-apps/grep/
root # chown -R portage:portage /usr/local/portage
root # pushd /usr/local/portage/sys-apps/grep
root # repoman manifest
root # popd 

或者执行下面命令安装
root # ebuild /usr/local/portage/sys-apps/grep/grep-2.21-r1.ebuild manifest

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
		emerge grep::localoverlay


例子2:
由于碰到pandoc的版本比较低,现在需要更像高版本的
可以用一个overlay直接装,操作大概如下
layman -a NewOverLayName
emerge pandoc

这里不用上面这样的办法,上面方法需要下载一个完整的overlay,这里不想这样
所以还是和local overlay一样,只要有ebuild文件即可
1.	首先需要到到下面这个网站上查找需要的ebuild文件
	http://gpo.zugaina.org/Overlays/bgo-overlay
	这里需要安装pandoc所以搜索pandoc
	下载需要的ebuild文件到指定目录下
	这里指定为/usr/local/portage/app-text/pandoc

	生成相应的manifest文件,这个过程还会下载相应的包
	pushd /usr/local/portage/app-text/pandoc
	repoman manifest
	popd

由于下载的包是不稳定版本,没有被gentoo官方unmask
所以这里需要在accept里添加下面的内容
在/etc/portage/package.accept_keywords里添加下面的内容
>=app-text/pandoc-1.16.0.2 ~amd64

之后就可以emerge pandoc了,不过这里由于依赖关系
所以还需要安装两外两个包,安装的时候就知道了,是cmark和pandoc-types
方法都一样
下载cmark的ebuild文件放到/usr/local/portage/dev-haskell/cmark 下
下载pandoc-types的ebuild文件放到/usr/local/portage/dev-haskell/pandoc-types 下

在/etc/portage/package.accept_keywords里添加下面的内容
>=dev-haskell/cmark-0.5.1 ~adm64
>=dev-haskell/pandoc-types-1.16.1 ~amd64
之后就可以安装高版本的pandoc了,解决了低版本无法识别markdown里index的问题

例子3:
比如现在想要调试或修改一个应用软件,这里用kdiff3作为例子

1. 首先可以安装正常的方法先安装或是通过emerge指定只下载kdiff3的源码
2. 解压源码,根据个人需要修改源码,重新打包源码,比如名字为kdiff3-0.9.98.tar.gz
3. 在local overlay 里拷贝一份kdiff3的ebuild文件,修改其中的SRC_URI
	SRC_URI="file:///usr/portage/distfiles/kdiff3-0.9.98.tar.gz"
	这样做的目的是为了不重新下载而是使用本地修改过的代码
4. 重新生成manifest
	ebuild /usr/local/portage/kde-misc/kdiff3/kdiff3-0.9.98.ebuild manifest
5. 安装修改过的kdiff3,这里需要指定使用的是哪个overlay,这里使用的是上面创建的名为mobzoverlay的overlay
	emerge -v kdiff3::mobzoverlay
```
