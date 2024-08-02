# ffmpeg 使用

## 获取帮助

	ffmpeg -h full

## 去除视频文件中的音频或是视频

    参数-vn / -an / -sn / -dn分别对应去除video,audio,subtitle,data stream

提取视频中的音频

	ffmpeg -i input.mp4 -vn output.ogg

去除视频中的音频

	ffmpeg -i input.mp4 -an video.mp4

## 截取音频/视频中的一段(两种方法)

	ffmpeg -ss 00:00:03.000 -t 5 -i input.mp4 output.mp4
	ffmpeg -i input.mp4 -ss 00:00:03.000 -to 5 output.mp4

## 单独合并音频和视频文件

合并音频和视频

    ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -strict experimental output.mp4

## 多视频合并

	ffmpeg -f concat -i list.txt output.mp4

其中list.txt内容如下

	file input1.mp4
	file input2.mp4

## 水印(watermark)

给视频添加静态水印

	ffmpeg -y -i input.mp4 -vf "drawtext=fontfile=luxirb.ttf: text='this is water mark' :x=10:y=10:fontsize=24:fontcolor=white:shadowy=2" output.mp4

在视频底部添加移动的水印

	ffmpeg -y -i input.mp4 -vf "drawtext=fontfile=Arial.ttf: text='this is water makr': y=h-line_h-10:x=(mod(2*n\,w+tw)-tw):fontsize=34:fontcolor=yellow:shadowy=2" -b:v 3000k output.mp4

将图片埋在视频中

	ffmpeg -y -i watermark.png -i input.mp4 -filter_complex "[0:v]geq=a='122':lum='lum(X,Y)':cb='cb(X,Y)':cr='cr(X,Y)'[topV];[1:v][topV]overlay=(W-w)/2:(H-h)/2" output.mp4

## 音频视频转码成可用于网页播放的格式webm(ffmpeg需要vorbis,vpx支持)

mkv转webm

	ffmpeg -y -i input.mkv -vcodec libvpx -cpu-used 1 -deadline realtime output.webm

aac转webm

	ffmpeg -y -i 00.aac -vcodec libvpx -cpu-used 1 -deadline realtime 00.webm

## 根据m3u8来下载视频

	ffmpeg -i https://path/to/index.m3u8 -c copy -bsf:a aac_adtstoasc output.mp4

## 制作mp4的m3u8文件

	ffmpeg -i demo.mp4 -b:v 1M -g 60 -hls_time 2 -hls_list_size 0 -hls_segment_size 500000 demo.m3u8

## 调整音频和视频音量大小

    ffmpeg -i demo1.mp4 -af "volumedetect" -f null /dev/null

    [Parsed_volumedetect_0 @ 0x5643a23edfd0] n_samples: 2641920
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] mean_volume: -42.5 dB
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] max_volume: -18.8 dB
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_18db: 3
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_19db: 19
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_20db: 38
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_21db: 88
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_22db: 198
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_23db: 255
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_24db: 509
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_25db: 1024
    [Parsed_volumedetect_0 @ 0x5643a23edfd0] histogram_26db: 1844

用如下命令将demo1.mp4文件的音量调大10dB(调小就写 -10dB),输出到output.mp4 件中

    ffmpeg -i demo1.mp4 -vcodec copy -af "volume=10dB" output.mp4

## 查看视频时长

    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 demo.mp4
    ffmpeg -i demo.mp4 2>&1 | grep Duration

## 编辑mp3的metadata(没有metadata在ncmpcpp显示为空)

    ffmpeg -i input.mp3 -c copy -metadata artist="singer name" -metadata title="song name" -metadata album="x" output.mp3

## 修改图片大小

可以先查看原图尺寸后修改

	ffprobe input.jpg

	Stream #0:0: Video: mjpeg (Baseline), yuvj444p(pc, bt470bg/unknown/unknown), 1842x2579 [SAR 300:300 DAR 1842:2579], 25 fps, 25 tbr, 25 tbn, 25 tbc

指定比例

	ffmpeg -i input.jpg -vf scale=1024:768 output.jpg

保存原图比例

	ffmpeg -i input.jpg -vf scale=1024:-1 output.jpg
	ffmpeg -i input.jpg -vf scale=-1:768 output.jpg
