FROM nvidia/opengl:base-ubuntu18.04

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

ENV LANG C.UTF-8

RUN dpkg --add-architecture i386

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
      ca-certificates git lsb-release sudo \
      curl \
      libgl1-mesa-dri \
      udev \
      vim \
      mesa-utils \
      libcap2-bin \
      wine-stable \
      tzdata \
      usbutils \
      nano \
      software-properties-common

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Installs PCSX2 daily from PPA

RUN add-apt-repository ppa:pcsx2-team/pcsx2-daily -y

RUN apt-get install -y pcsx2-unstable

RUN useradd -d /home/pi -G sudo -m pi

RUN echo "pi ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pi

WORKDIR /home/pi

USER pi

RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
RUN cd RetroPie-Setup \
    && sudo chmod +x retropie_setup.sh \
    && sudo ./retropie_packages.sh setup basic_install
    
    
# Install USB resetting utility
COPY reset_controller.py /usr/bin/reset_controller.py
RUN chmod +x /usr/bin/reset_controller.py

# And install script hooks

COPY runcommand-onstart.sh /opt/retropie/configs/all/runcommand-onstart.sh 
RUN chmod +x /opt/retropie/configs/all/runcommand-onstart.sh 

# Edit this file in your persistent storage to use all or part of the name provided from "lsusb" to reset the controller on each start 
RUN touch /opt/retropie/configs/all/controller_names && chown pi:pi /opt/retropie/configs/all/controller_names

# and Installs RetroPie + optional modules declared in install.sh
COPY --chown=pi install_retropie_addons.sh /tmp/install_retropie_addons.sh
COPY --chown=pi addons.cfg /tmp/addons.cfg
COPY --chown=pi post_install.sh /tmp/post_install.sh


RUN bash /tmp/install_retropie_addons.sh
RUN bash /tmp/post_install.sh

COPY --chown=pi ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["run"]
