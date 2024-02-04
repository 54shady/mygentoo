first off, on ubuntu22.04 install feishu, pack opt file in tar

	tar cvf feishu.tar /opt/bytedance/feishu

extra on gentoo opt

	tar xvf feishu.tar -C .
	/opt/feishu/

run feishu

	/opt/feishu/feishu

添加文件(/usr/share/applications/feishu.desktop)

	[Desktop Entry]
	Type=Application
	Terminal=false
	Categories=Office;Dictionary;Education;Qt;;
	Name=Feishu
	GenericName=Multiformat Dictionary
	Comment=A feature-rich dictionary lookup program
	Icon=goldendict
	Exec=/opt/feishu/feishu
