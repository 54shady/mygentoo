# Linux 音频子系统

## 常用软件对pulseaudio和alsa支持情况

### MPV

mpv 通过--ao= 参数来选择对应的声音输出驱动

查看可配置项目

	mpv --ao=help
	Available audio outputs:
	  pulse            PulseAudio audio output
	  alsa             ALSA audio output
	  null             Null audio output
	  pcm              RAW PCM/WAVE file writer audio output

使用alsa

	mpv --ao=alsa demo.mp4

将视频文件中的音频dump到文件中(输出pcm数据文件)

	mpv --ao=pcm demo.mkv

### alsa-utils

使用aplay -L查看声卡设备

	default:CARD=PCH
	sysdefault:CARD=PCH
	...
	pulse

使用aplay -D 来指定使用声卡设备

	aplay -D sysdefault:CARD=PCH demo.mp3

让aplay使用pulseaudio来输出声音

	aplay -D pulse demo.mp3

此时如果没有启动pulseaudio,会自动拉起pulseaudio服务

	/usr/bin/pulseaudio --start --log-target=syslog

测试左右声道

	speaker-test -t wav -c 2

## Qemu

查看qemu音频的后端支持

	qemu -audio-help

使用pulseaudio作为后端

	qemu -audiodev pa

将虚拟机中的音频写入到文件中

	qemu -audiodev wav,path=/path/to/dump.wav
