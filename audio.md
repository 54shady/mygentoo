# Linux 音频子系统

## 查看声卡被应用占用情况

	fuser -v /dev/snd/*

## alsa和pulseaudio关系

1. alsa是linux内核中的音频子系统,可以通过该子系统直接操作控制声卡
2. pulseaudio位于应用层,能够将多路音频混合后再输出到声卡,满足多个应用同时使用声卡

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
	plughw:CARD=HDA,DEV=0
	hw:CARD=HDA,DEV=0
	...
	pulse

使用aplay -D 来指定使用声卡设备格式如下

	aplay -D plughw:CARD=HDA,DEV=0 /usr/share/sounds/alsa/Noise.wav

或者用aplay -l查看声卡设备号(HDA对应的声卡是1)

	aplay -D plughw:1,0 /usr/share/sounds/alsa/Noise.wav

使用系统默认声卡(通过内核alsa框架,不需要pulseaudio参与,不能多个应用同时播放)

	aplay -D sysdefault:CARD=PCH /usr/share/sounds/alsa/Noise.wav

让aplay使用pulseaudio来输出声音(可以支持多个应用同时播放)

	aplay -D pulse /usr/share/sounds/alsa/Noise.wav

此时如果没有启动pulseaudio,会自动拉起pulseaudio服务

	/usr/bin/pulseaudio --start --log-target=syslog

测试左右声道

	speaker-test -t wav -c 2

## QEMU中使用音频

查看qemu音频的后端支持

	qemu -audio-help

使用pulseaudio作为后端

	qemu -audiodev pa

将虚拟机中的音频写入到文件中

	qemu -audiodev wav,path=/path/to/dump.wav
