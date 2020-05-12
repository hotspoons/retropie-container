FROM ubuntu:18.04



ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
      ca-certificates git lsb-release sudo \
      curl `# for install.sh` \
      libgl1-mesa-dri \
      udev \
      vim \
      mesa-utils \
      software-properties-common


RUN sudo dpkg --add-architecture i386
RUN add-apt-repository ppa:pcsx2-team/pcsx2-daily -y

RUN apt-get install -y pcsx2-unstable


RUN useradd -d /home/pi -G sudo -m pi

RUN echo "pi ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pi

#RUN export uid=1000 gid=1000 && \
#    echo "pi:x:${uid}:${gid}:Developer,,,:/home/pi:/bin/bash" >> /etc/passwd && \
#    echo "pi:x:${uid}:" >> /etc/group 

WORKDIR /home/pi

USER pi

# https://raw.githubusercontent.com/meleu/RetroPie-joystick-selection/master/install.sh
COPY --chown=pi install.sh /tmp/install.sh

RUN bash /tmp/install.sh




COPY --chown=pi ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["run"]
