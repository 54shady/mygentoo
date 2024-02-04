Config git sendemail to using 163mail to send patch(~/.gitconfig 添加如下,密码配置不填则需要手动输入)

[sendemail]
	smtpEncryption = ssl
	smtpServer = smtp.163.com
	smtpUser = M_O_Bz@163.com
	smtpServerPort = 587
	smtpPass = "My163Password"

generate the patch file and sendit

	git format-patch HEAD^
	git send-email \
		--subject "subject of this mail" \
		--from M_O_Bz@163.com \
		--cc tom@mail.com \
		--to jerry@mail.com 0001.patch
