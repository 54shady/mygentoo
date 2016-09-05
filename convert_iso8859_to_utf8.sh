#!/bin/bash

# 使用grep发现如果文件是ISO 8859的编码无法正常搜索
# 需要将文件编码装换为UTF8
# 此脚本将将files数组里的所有文件都转化为UTF8编码格式
# 使用下面的命令查找所有是8859编码的文件,找到后放到数组中
# file `find . -name "*.[ch]"` | grep 8859

files=(
file.c                                     
file.h                                           
)

# 遍历所有文件,先把转化后的文件保存为名字_tmp
# 最后在覆盖源文件
for file in ${files[@]}
do
	file_tmp=${file}"_tmp"
	iconv -f ISO-8859-1 -t UTF-8 $file > $file_tmp 
	mv $file_tmp $file
done
