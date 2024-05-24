#!/usr/bin/env python
# coding=utf-8

import bluetooth

server_addr = 'xx:xx:xx:xx:xx:xx'  # 请把这里替换为你的服务端设备的蓝牙地址
port = 1

sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
sock.connect((server_addr, port))

while True:
    msg = input('Enter: ')
    sock.send(msg)

sock.close()
