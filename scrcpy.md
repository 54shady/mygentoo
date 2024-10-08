# Android phone on linux using [scrcpy](https://github.com/Genymobile/scrcpy/)

simple setup

1. enable the usb debug on android phone
2. on host run adb kill-server and adb shell to test it
3. run scrcpy on host (app-mobilephone/scrcpy)

using software to fix issue:(ERROR: Could not create renderer: Couldn't find matching render driver)

    scrcpy --render-driver=software

## adb over TCP/IP(电脑和手机要在同一个网络中)

Get Phone IP address, in Settings-> About phone -> Status, or by executing this command:

    adb shell ip route | awk '{print $9}'

    192.168.43.251

Enable adb over TCP/IP on your Phone

    adb tcpip 5555

Unplug your device, Connect device with command below

    adb connect DEVICE_IP:5555
    adb connect 192.168.43.251:5555
    adb shell
    scrcpy --render-driver=software

or do it automatically in scrcpy

    scrcpy --render-driver=software --tcpip=192.168.43.251:5555

Run adb disconnect once you're done.

    adb disconnect

Restore to adb usb mode with below command(plug usb cable first)

    adb usb

## Video4Linux(media-video/v4l2loopback)

[scrcpy v4l2](https://github.com/Genymobile/scrcpy/blob/master/doc/v4l2.md)

install and load v4l2loopback module(a new device /dev/videoN will be create)

    sudo modprobe v4l2loopback

list the video devices

    sudo v4l2loopback-ctl list

    OUTPUT          CAPTURE         NAME
    /dev/video0     /dev/video0     Dummy video device (0x0000)

To start scrcpy using a v4l2 sink

    sudo scrcpy --v4l2-sink=/dev/video0 --render-driver=software

using -s to select over multiple device

    ERROR: Multiple (2) ADB devices:
    ERROR:     --> (tcpip)  192.168.43.162:5555             device  Note9
    ERROR:     --> (tcpip)  192.168.43.183:5555             device  Note9

    sudo scrcpy --v4l2-sink=/dev/video0 --render-driver=software -s 192.168.43.162:5555

ERROR: Could not find v4l2 muxer

    ffmpeg add v4l use flag

using ffplay to play(ffmpeg add sdl use flag will get ffplay install)

    ffplay -i /dev/video0

## OTG mode(手机需要通过usb线和主机连接)

主机上的键盘和鼠标可以直接操作手机,变成了手机外接的otg设备

先列出所有的设备 adb devices

    List of devices attached
    923QEDUM2263B   device
    192.168.43.162:5555     device
    192.168.43.183:5555     device

连接其中一个

    adb -s 923QEDUM2263B shell

run in otg mode

    scrcpy --render-driver=software --otg

通过-s来指定用usb线连接的设备

    scrcpy --render-driver=software --otg -s 923QEDUM2263B

## 使用android设备里的输入法(否者只是输入字母,不会关联中文输入法)

通过传递参数uhid, 在host pc上键盘按下后能够出发android设备里的输入法

    scrcpy --keyboard=uhid --render-driver=software --tcpip=192.168.43.126:5555

## rotate

显示旋转90度

	scrcpy --lock-video-orientation=1
