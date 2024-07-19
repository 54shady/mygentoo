# Camera Usage

## basic

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

查看控制参数

	v4l2-ctl -d /dev/video0 -l

	User Controls

						 brightness 0x00980900 (int)    : min=0 max=255 step=1 default=128 value=128
						   contrast 0x00980901 (int)    : min=0 max=100 step=1 default=32 value=32
						 saturation 0x00980902 (int)    : min=0 max=100 step=1 default=64 value=64
								hue 0x00980903 (int)    : min=-180 max=180 step=1 default=0 value=0
			white_balance_automatic 0x0098090c (bool)   : default=1 value=1
							  gamma 0x00980910 (int)    : min=90 max=150 step=1 default=120 value=120
			   power_line_frequency 0x00980918 (menu)   : min=0 max=3 default=1 value=1 (50 Hz)
		  white_balance_temperature 0x0098091a (int)    : min=2800 max=6500 step=10 default=4600 value=4600 flags=inactive
						  sharpness 0x0098091b (int)    : min=0 max=7 step=1 default=3 value=3
			 backlight_compensation 0x0098091c (int)    : min=0 max=2 step=1 default=1 value=1

	Camera Controls

					  auto_exposure 0x009a0901 (menu)   : min=0 max=3 default=3 value=3 (Aperture Priority Mode)
			 exposure_time_absolute 0x009a0902 (int)    : min=2 max=1250 step=1 default=156 value=156 flags=inactive
		 exposure_dynamic_framerate 0x009a0903 (bool)   : default=0 value=1
							privacy 0x009a0910 (bool)   : default=0 value=0

获取并设置参数brightness

	v4l2-ctl -d /dev/video0 --get-ctrl brightness
	v4l2-ctl -d /dev/video0 --set-ctrl 'brightness=200'

查询摄像头能够支持的格式

	v4l2-ctl --list-formats

	ioctl: VIDIOC_ENUM_FMT
			Type: Video Capture

			[0]: 'MJPG' (Motion-JPEG, compressed)
			[1]: 'YUYV' (YUYV 4:2:2)

可以先通过命令查看支持的格式和分辨率

	v4l2-ctl --device=/dev/video0 --list-formats-ext

	ffmpeg -f v4l2 -list_formats all -i /dev/video0

	[video4linux2,v4l2 @ 0x572d1cc5e680] Compressed:       mjpeg :          Motion-JPEG : 1280x720 320x180 320x240 352x288 640x360 640x480 848x480 960x540 1920x1080
	[video4linux2,v4l2 @ 0x572d1cc5e680] Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480 320x180 320x240 352x288 640x360 848x480 960x540 1280x720 1920x1080

## 抓取mjpg格式图像

通过摄像头拍摄一张图片(默认用MJPG格式)

	v4l2-ctl -d /dev/video0 \
		--set-fmt-video=width=1920,height=1080,pixelformat='MJPG'\
		--stream-mmap --stream-skip=3 \
		--stream-to=/tmp/isp.out \
		--stream-count=10 --stream-poll

查看格式如下(file /tmp/isp.out)

	/tmp/isp.out: JPEG image data, baseline, precision 8, 1920x1080, components 3

显示一帧

	sxiv /tmp/isp.out

全部循环显示

	W=1920;H=1080; mplayer /tmp/isp.out -loop 0 -demuxer rawvideo -fps 30 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=MJPG

##  抓取raw格式图像

使用YUYV格式抓取raw图,并用mplayer显示

	v4l2-ctl -d /dev/video0 \
		--set-fmt-video=width=640,height=480,pixelformat='YUYV' \
		--stream-mmap --stream-skip=3 \
		--stream-to=/tmp/isp.out \
		--stream-count=10 --stream-poll

查看格式如下(file /tmp/isp.out)

	/tmp/isp.out: International EBCDIC text, with very long lines (65536), with no line terminators

显示图像

	W=640;H=480; mplayer /tmp/isp.out -loop 0 -demuxer rawvideo -fps 30 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=YUY2
	W=640;H=480; mplayer /tmp/isp.out -loop 0 -demuxer rawvideo -fps 1 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=YUY2

## 使用ffmpeg操作

打开摄像头

	ffplay /dev/video0
