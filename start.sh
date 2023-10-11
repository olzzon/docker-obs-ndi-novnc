#!/bin/bash

export USER=headless

echo "********************* Parse env arguments to OBS browse start **********"
if [ $URL ]; then
  sed -i "s|URL_REPLACE|$URL|g" /home/headless/.config/obs-studio/basic/scenes/Untitled.json;
fi

if [ $SCENE ]; then
  sed -i 's|/usr/bin/obs|/usr/bin/obs --scene "$SCENE" |' /home/headless/.fluxbox/startup;
fi


echo "********************* Start Avahi mDNS service ****************************"
printf "headless\n" | sudo -S -k /etc/init.d/avahi-daemon start --no-rlimits

echo "********************* Starting NO VNC SERVER  PORT 6919 *******************"
websockify -D --web=/usr/share/novnc/ --cert=/home/ubuntu/novnc.pem 6919 localhost:5900 &

echo "********************* Starting VNC SERVER PORT 5900 **********************'"
export DISPLAY=:0
/opt/TurboVNC/bin/vncserver  -geometry 1920x1080 -securitytypes none :0 &
sleep 1
/opt/VirtualGL/bin/vglrun /usr/bin/startfluxbox &

/bin/bash
