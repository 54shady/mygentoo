## 提取视频中的音频

	ffmpeg -i input.mp4 -vn output.ogg

## 去除视频中的音频

	ffmpeg -i input.mp4 -an video.mp4

## 截取视频中的一段(两种方法)

	ffmpeg -ss 00:00:03.000 -t 5 -i input.mp4 output.mp4
	ffmpeg -i input.mp4 -ss 00:00:03.000 -to 5 output.mp4

## 多视频合并

	ffmpeg -f concat -i list.txt output.mp4

其中list.txt内容如下

	file input1.mp4
	file input2.mp4

## watermark

给视频添加静态水印

	ffmpeg -y -i input.mp4 -vf "drawtext=fontfile=luxirb.ttf: text='this is water mark' :x=10:y=10:fontsize=24:fontcolor=white:shadowy=2" output.mp4

在视频底部添加移动的水印

	ffmpeg -y -i input.mp4 -vf "drawtext=fontfile=Arial.ttf: text='this is water makr': y=h-line_h-10:x=(mod(2*n\,w+tw)-tw):fontsize=34:fontcolor=yellow:shadowy=2" -b:v 3000k output.mp4

将图片埋在视频中

	ffmpeg -y -i watermark.png -i input.mp4 -filter_complex "[0:v]geq=a='122':lum='lum(X,Y)':cb='cb(X,Y)':cr='cr(X,Y)'[topV];[1:v][topV]overlay=(W-w)/2:(H-h)/2" output.mp4

