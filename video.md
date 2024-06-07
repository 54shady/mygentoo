查看摄像头设备(ThinkBook14G5)

	v4l2-ctl --list-devices

	Integrated Camera: Integrated C (usb-0000:00:14.0-6):
			/dev/video0
			/dev/video1
			/dev/video2
			/dev/video3
			/dev/media0
			/dev/media1

查询详细信息

	v4l2-ctl --device=/dev/video0 --all

查询摄像头能够支持的格式

	v4l2-ctl --list-formats

	ioctl: VIDIOC_ENUM_FMT
			Type: Video Capture

			[0]: 'MJPG' (Motion-JPEG, compressed)
			[1]: 'YUYV' (YUYV 4:2:2)

	或者显示详细信息
	v4l2-ctl --list-formats-ext

	ffmpeg -f v4l2 -list_formats all -i /dev/video0

	[video4linux2,v4l2 @ 0x572d1cc5e680] Compressed:       mjpeg :          Motion-JPEG : 1280x720 320x180 320x240 352x288 640x360 640x480 848x480 960x540 1920x1080
	[video4linux2,v4l2 @ 0x572d1cc5e680] Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480 320x180 320x240 352x288 640x360 848x480 960x540 1280x720 1920x1080

通过摄像头拍摄一张图片(默认用MJPG格式)

	v4l2-ctl -d /dev/video0 --set-fmt-video=width=1632,height=1224 --stream-mmap --stream-skip=3 --stream-to=/tmp/isp.out --stream-count=10 --stream-poll
	sxiv /tmp/isp.out

使用YUYV格式

	v4l2-ctl -d /dev/video0 --set-fmt-video=width=1632,height=1224,pixelformat='YUYV' --stream-mmap --stream-skip=3 --stream-to=/tmp/isp.out --stream-count=10 --stream-poll

打开摄像头

	ffplay /dev/video0
