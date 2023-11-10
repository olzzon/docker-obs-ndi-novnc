FROM ubuntu:22.04
MAINTAINER github@olzzon.dk

EXPOSE 6919 
EXPOSE 5900-5901
EXPOSE 4455
EXPOSE 5959-5980
EXPOSE 6960-6980
EXPOSE 7960-7980

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen 

# INSTALL SYSTEM:
RUN apt-get update
RUN apt-get install -y sudo software-properties-common
RUN apt-get install -y wget net-tools curl openssh-client nano

# depencies headless:
RUN apt-get install -y x11vnc
RUN apt-get install -y xvfb fluxbox
RUN apt-get install -y novnc websockify

RUN apt-get install -y glmark2 geany libglu1-mesa libxv1 libxt6 xauth x11-xkb-utils iproute2 x11-apps

RUN wget https://downloads.sourceforge.net/project/virtualgl/2.6.5/virtualgl_2.6.5_amd64.deb
RUN dpkg -i virtualgl_2.6.5_amd64.deb
RUN rm virtualgl_2.6.5_amd64.deb

RUN wget https://downloads.sourceforge.net/project/turbovnc/2.2.6/turbovnc_2.2.6_amd64.deb
RUN dpkg -i turbovnc_2.2.6_amd64.deb
RUN rm turbovnc_2.2.6_amd64.deb

# dependency mDNS:
RUN apt-get install -y avahi-daemon avahi-utils
ADD avahi-daemon.conf /etc/avahi/avahi-daemon.conf
RUN mkdir -p /var/run/dbus

# dependencies VLC AND OBS:
RUN apt-get install -y vlc
RUN add-apt-repository ppa:obsproject/obs-studio
RUN apt-get install -y obs-studio

# COPY STARTUP SCRIPT:
COPY start.sh /start.sh
RUN chmod a+x /start.sh

# SETUP USER:
WORKDIR /usr/app
RUN useradd -ms /bin/bash -p headless headless
RUN echo headless:headless | chpasswd
RUN usermod -aG sudo headless

# SETUP VNC STUFF:
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html
RUN mkdir /home/headless/.vnc

# SETUP FLUXBOX AND AUTOSTART OBS:
RUN mkdir /home/headless/.fluxbox
RUN echo "sh &\n/opt/VirtualGL/bin/vglrun /usr/bin/obs &\nexec fluxbox" >> /home/headless/.fluxbox/startup
RUN chown -R headless /home/headless

# INSTALL NDI:
WORKDIR /tmp
ENV LIBNDI_INSTALLER_NAME="Install_NDI_SDK_v5_Linux"
ENV LIBNDI_INSTALLER="${LIBNDI_INSTALLER_NAME}.tar.gz"

RUN curl -L -o ${LIBNDI_INSTALLER} https://downloads.ndi.tv/SDK/NDI_SDK_Linux/$LIBNDI_INSTALLER -f --retry 5
RUN tar -xf ${LIBNDI_INSTALLER}
RUN yes | PAGER="cat" sh ${LIBNDI_INSTALLER_NAME}.sh
RUN rm -rf ndisdk
RUN mv "NDI SDK for Linux" ndisdk
RUN cp -P ndisdk/lib/x86_64-linux-gnu/* /usr/local/lib/
RUN ldconfig
RUN echo libndi installed to /usr/local/lib/
RUN ls -la /usr/local/lib/libndi*
RUN rm -rf ndisdk

# INSTALL OBS NDI PLUGIN:
WORKDIR /tmp
RUN curl -L -o obs-ndi-4.11.1-linux-x86_64.deb https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/obs-ndi-4.11.1-linux-x86_64.deb -f --retry 5
RUN dpkg -i obs-ndi-4.11.1-linux-x86_64.deb

# BUILD ARDOUR:
WORKDIR /tmp

RUN apt-get install -y libboost-dev libasound2-dev libglibmm-2.4-dev libsndfile1-dev
RUN apt-get install -y libcurl4-gnutls-dev libarchive-dev liblo-dev libtag-extras-dev
RUN apt-get install -y vamp-plugin-sdk librubberband-dev libudev-dev libnfft3-dev
RUN apt-get install -y libaubio-dev libxml2-dev libusb-1.0-0-dev
RUN apt-get install -y libpangomm-1.4-dev liblrdf0-dev libsamplerate0-dev
RUN apt-get install -y libserd-dev libsord-dev libsratom-dev liblilv-dev
RUN apt-get install -y libgtkmm-2.4-dev libsuil-dev
RUN apt-get install -y libpulse-dev libtag1-dev
RUN apt-get install -y python3 python-is-python3 git pkg-config

WORKDIR /
RUN git clone git://git.ardour.org/ardour/ardour.git ardour
WORKDIR /ardour
#RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/a/ardour/ardour_5.12.0-3.dsc
#RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/a/ardour/ardour_5.12.0.orig.tar.bz2
#RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/a/ardour/ardour_5.12.0-3.debian.tar.xz

#RUN dpkg-source -x ardour_5.12.0-3.dsc

#WORKDIR /tmp
#RUN curl https://waf.io/waf-2.0.26.tar.bz2 | tar xj
#WORKDIR /tmp/waf-2.0.26

#RUN patch -p1 < /build-ardour/ardour-5.12.0/tools/waflib.patch
#RUN ./waf-light -v --make-waf --tools=misc,doxygen,/build-ardour/ardour-5.12.0/tools/autowaf.py --prelude=''
#RUN cp ./waf /build-ardour/ardour/waf

WORKDIR /ardour
RUN ./waf configure --with-backend=alsa
RUN ./waf build -j16
RUN ./waf install

# COPY OBS USERSETTINGS:
RUN mkdir /home/headless/.config
COPY config/ /home/headless/.config

# SET USER:
RUN chown -R headless /home/headless/
USER headless
WORKDIR /home/headless

CMD ["sh","/start.sh"]

# SET VOLUMES:
VOLUME ["/var/run/dbus"]

