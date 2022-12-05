FROM x86/ubuntu:2004
MAINTAINER zeroway

RUN apt-get update && apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN	DEBIAN_FRONTEND=noninteractive apt-get -y install xserver-xspice x11-xserver-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install xfce4
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install tango-icon-theme xfce4-notifyd xfce4-terminal xubuntu-icon-theme dbus-x11 sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install umlet

ADD	spiceqxl.xorg.conf /etc/X11/
ADD	resolution.desktop /etc/xdg/autostart/
ADD	keyboard.desktop /etc/xdg/autostart/
ADD run.sh /root/
VOLUME ["/home"]
EXPOSE 5900
CMD /root/run.sh
