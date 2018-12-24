#!/usr/bin/env python
# coding=utf-8

import shutil
import os


def ncopy(src_file_or_dir, dst_dir, target_name=None):
    """
    A powerfull copy function

    @src_file_or_dir can be a dir or a file
    @dst_dir the destination directory

    cp a_dir to dst_dir/a_dir
    cp a_file to dst_dir/a_file

    @target_name
    leave the target_name empty
    if u don't wanna change the file name
    """

    # find out the absolute path of src_file_or_dir and dst
    abs_src = os.path.abspath(src_file_or_dir)
    abs_dst_dir = os.path.abspath(dst_dir)
    if not os.path.exists(abs_dst_dir):
        shutil.os.makedirs(abs_dst_dir)

    # rename the file or keey the origin file name
    # split src_file_or_dir file path and file name
    fp, fn = os.path.split(abs_src)
    if target_name is None:
        dst_file_name = fn
    else:
        dst_file_name = target_name

    # the absolute destination file path
    abs_dst = os.path.join(abs_dst_dir, dst_file_name)

    if (os.path.isdir(abs_src)):
        if os.path.exists(abs_dst):
            shutil.rmtree(abs_dst)
            shutil.copytree(abs_src, abs_dst)
        else:
            shutil.copytree(abs_src, abs_dst)
    elif (os.path.isfile(abs_src)):
        shutil.copy2(abs_src, abs_dst)
    else:  # links, pipes, chars, etc
        shutil.copy2(abs_src, abs_dst)


if __name__ == '__main__':
    with open('backups.txt') as f:
        files = f.read().splitlines()

    for f in files:
        src = f
        dst = os.getcwd() + f
        ncopy(src, os.path.dirname(dst))
