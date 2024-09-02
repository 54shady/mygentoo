# Camera Usage(ThinkBook14G5)

## basic

查看usb摄像头信息 lsusb

	Bus 003 Device 005: ID 04f2:b7b5 Chicony Electronics Co., Ltd Integrated Camera

查看摄像头设备

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

查询摄像头能够支持的格式和分辨率

	v4l2-ctl --list-formats

	ioctl: VIDIOC_ENUM_FMT
			Type: Video Capture

			[0]: 'MJPG' (Motion-JPEG, compressed)
			[1]: 'YUYV' (YUYV 4:2:2)

	v4l2-ctl --device=/dev/video0 --list-formats-ext

	ioctl: VIDIOC_ENUM_FMT
			Type: Video Capture

			[0]: 'MJPG' (Motion-JPEG, compressed)
					Size: Discrete 1280x720
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 320x180
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 320x240
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 352x288
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 640x360
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 640x480
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 848x480
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 960x540
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 1920x1080
							Interval: Discrete 0.033s (30.000 fps)
			[1]: 'YUYV' (YUYV 4:2:2)
					Size: Discrete 640x480
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 320x180
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 320x240
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 352x288
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 640x360
							Interval: Discrete 0.033s (30.000 fps)
					Size: Discrete 848x480
							Interval: Discrete 0.050s (20.000 fps)
					Size: Discrete 960x540
							Interval: Discrete 0.067s (15.000 fps)
					Size: Discrete 1280x720
							Interval: Discrete 0.100s (10.000 fps)
					Size: Discrete 1920x1080
							Interval: Discrete 0.200s (5.000 fps)

使用ffmpeg可以看到mjpeg是压缩的,yuyv422是原数据

	ffmpeg -f v4l2 -list_formats all -i /dev/video0

		[video4linux2,v4l2 @ 0x572d1cc5e680] Compressed:       mjpeg :          Motion-JPEG : 1280x720 320x180 320x240 352x288 640x360 640x480 848x480 960x540 1920x1080
		[video4linux2,v4l2 @ 0x572d1cc5e680] Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480 320x180 320x240 352x288 640x360 848x480 960x540 1280x720 1920x1080

## 抓取mjpg格式图像

通过摄像头拍摄一张图片(默认用MJPG格式)

	v4l2-ctl -d /dev/video0 \
		--set-fmt-video=width=1920,height=1080,pixelformat='MJPG'\
		--stream-mmap --stream-skip=3 \
		--stream-to=/tmp/a.jpg \
		--stream-count=1 --stream-poll

查看格式如下(file /tmp/a.jpg)

	/tmp/a.jpg: JPEG image data, baseline, precision 8, 1920x1080, components 3

抓10张图片

	v4l2-ctl -d /dev/video0 \
		--set-fmt-video=width=1920,height=1080,pixelformat='MJPG'\
		--stream-mmap --stream-skip=3 \
		--stream-to=/tmp/stream.out \
		--stream-count=10 --stream-poll

查看格式如下(file /tmp/isp.out)

	/tmp/stream.out: JPEG image data, baseline, precision 8, 1920x1080, components 3

显示一帧

	sxiv /tmp/stream.out

全部循环显示

	W=1920;H=1080; mplayer /tmp/stream.out -loop 0 -demuxer rawvideo -fps 30 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=MJPG

##  抓取raw格式图像

使用YUYV格式抓取raw图,并用mplayer显示

	v4l2-ctl -d /dev/video0 \
		--set-fmt-video=width=640,height=480,pixelformat='YUYV' \
		--stream-mmap --stream-skip=3 \
		--stream-to=/tmp/isp.out \
		--stream-count=10 --stream-poll

查看格式如下(file /tmp/isp.out)

	isp.out: data

显示图像

	W=640;H=480; mplayer /tmp/isp.out -loop 0 -demuxer rawvideo -fps 30 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=YUY2
	W=640;H=480; mplayer /tmp/isp.out -loop 0 -demuxer rawvideo -fps 1 -rawvideo w=${W}:h=${H}:size=$((${W}*${H}*2)):format=YUY2

## 将摄像头视频保存成文件

	ffmpeg -f v4l2 -pixel_format nv12 -framerate 30 -video_size 1920x1080 -i /dev/video0 out.h264

## 摄像头预览 (ffplay延迟更大,gst延迟很小)

	ffplay /dev/video0
	gst-launch-1.0 v4l2src device=/dev/video0 ! jpegdec ! autovideosink

## gst basic intro

[参考1: streamer-tool](https://gstreamer.freedesktop.org/documentation/tutorials/basic/gstreamer-tools.html?gi-language=c)

gst-launch-1.0 PIPELINE-DESCRIPTION

elements : 在pipline-description中通过感叹号来分割elements,比如下面命令

	gst-launch-1.0 videotestsrc ! videoconvert ! autovideosink

其中videotestsrc, videoconvert, autovideosink三个都是elements

properties : 附属于elements后面的就是elements的属性(比如下面的pattern=ball)

	gst-launch-1.0 videotestsrc pattern=ball ! autovideosink

## 使用gstream操作摄像头

source:

	gst-inspect-1.0 | grep Video | grep Source
	video4linux2:  v4l2src: Video (video4linux2) Source

dec:

	gst-inspect-1.0 | grep jpegdec
	jpeg:  jpegdec: JPEG image decoder

sink:

	gst-inspect-1.0 | grep 'Video sink'
	ximagesink:  ximagesink: Video sink
	xvimagesink:  xvimagesink: Video sink

pipeline:

	gst-launch-1.0 v4l2src ! jpegdec ! xvimagesink

在wayland系统中使用x的插件会有如下报错

	gst-launch-1.0 v4l2src ! jpegdec ! xvimagesink
		ERROR: from element /GstPipeline:pipeline0/GstXvImageSink:xvimagesink0: Could not initialise Xv output

	gst-launch-1.0 v4l2src ! jpegdec ! ximagesink
		ERROR: from element /GstPipeline:pipeline0/GstXImageSink:ximagesink0: Could not initialise X output

需要使用waylandsink(在ubuntu桌面系统中切换到weston)

	apt install -y gstreamer1.0-plugins-bad
	gst-launch-1.0 v4l2src ! jpegdec ! waylandsink

将摄像头采集的mjpeg图像显示在显示器上(需要jpegdec是因为摄像头默认采集的是mjpeg的压缩数据)

	gst-launch-1.0 v4l2src ! jpegdec ! xvimagesink

	gst-launch-1.0 -v v4l2src device="/dev/video0" ! 'image/jpeg,width=1920,height=1080' ! jpegdec ! autovideosink
	gst-launch-1.0 -v v4l2src device="/dev/video0" ! 'image/jpeg,width=1920,height=1080' ! jpegdec ! videoconvert ! autovideosink

	下面这条命令添加了jpegparse视频会卡顿
	gst-launch-1.0 -v v4l2src device="/dev/video0" ! 'image/jpeg,width=1920,height=1080' ! jpegparse ! jpegdec ! videoconvert ! autovideosink

## Camera streaming with RTSP / RTMP

### 使用源码中的测试用例test-launch

安装必要依赖

	apt install -y meson \
		libglib2.0-dev \
		libgstreamer-plugins-bad1.0-dev \
		libglib2.0-dev \
		libgstreamer1.0-dev \
		libgstrtspserver-1.0-dev \
		libgstreamer-plugins-bad1.0-dev

下载源代码配置编译

	wget https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-1.18.4.tar.xz
	tar xvf gst-rtsp-server-1.18.4.tar.xz
	cd gst-rtsp-server-1.18.4
	mkdir build && cd build
	meson --prefix=/usr --wrap-mode=nofallback -D buildtype=release -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ -D package-name="GStreamer 1.18.4" ..
	ninja -j8

使用usb摄像头来推拉流

	cd example
	sudo ./test-launch "( v4l2src device=/dev/video0 io-mode=dmabuf ! image/jpeg,width=1920,height=1080,framerate=30/1 ! rtpjpegpay  name=pay0 )"

在本地拉流(客户端延时很大)

	ffplay -rtsp_transport tcp rtsp://127.0.0.1:8554/test
	gst-launch-1.0 rtspsrc location=rtsp://127.0.0.1:8554/test ! rtpjpegdepay ! jpegdec ! autovideosink

### 直接使用gst推流(不使用编译的源代码)

往ip地址为127.0.0.1的主机端口8554推流(这里是本地推本地收)

	gst-launch-1.0 v4l2src device=/dev/video0 io-mode=dmabuf ! image/jpeg,width=1920,height=1080,framerate=30/1 ! rtpjpegpay ! queue !        udpsink host=127.0.0.1 port=8554 sync=false

在主机ip地址为127.0.0.1上使用gst拉流(很卡顿)

	gst-launch-1.0 udpsrc port=8554 ! "application/x-rtp, payload=127" ! rtpjpegdepay ! jpegdec ! autovideosink sync=false
