## aria2 + apache + yaaw 下载服务器搭建

[安装apache参考https://wiki.gentoo.org/wiki/Apache](https://wiki.gentoo.org/wiki/Apache)

使用的是gentoo的portage,没有使用第三方overlay,如果本地有第三方overlay可能在安装的时候会有错误

所有操作都使用root用户

安装aria2

	添加必要的USE
	echo "net-misc/aria2 bittorrent metalink" >> /etc/portage/package.use/use
	emerge -v net-misc/aria2

配置aria2

	mkdir -p /etc/aria2/
	touch /etc/aria2/aria2.session
	添加/etc/aria2/aria2.conf

[aria2.conf内容https://github.com/54shady/mygentoo/blob/i56500/etc/aria2/aria2.conf](https://github.com/54shady/mygentoo/blob/i56500/etc/aria2/aria2.conf)

安装apache

	emerge -v www-servers/apache

在/etc/hosts中确保有下面的内容(其中zeroway是hostname)

	127.0.0.1 zeroway

启动服务器

	sudo /etc/init.d/apache2 start

测试apache是否安装成功,在浏览器里输入服务器IP(192.168.7.103)就可以访问了

修改apache默认访问目录

从apache的配置文件/etc/apache2/vhosts.d/default_vhost.include
中可以知道默认的访问目录是/var/www/localhost/htdocs
这里修改为如下:

	DocumentRoot "/var/www/html"
	<Directory "/var/www/html">

安装yaaw

	git clone https://github.com/binux/yaaw.git /var/www/html

启动aria2

	aria2c --conf-path=/etc/aria2/aria2.conf

再次在浏览器中访问测试是否安装成功

