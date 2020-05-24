FROM arm32v7/debian:buster-slim

ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
      ca-certificates git lsb-release sudo \
      curl \
      libgl1-mesa-dri \
      udev \
      vim \
      mesa-utils \
      libcap2-bin \
      tzdata \
      usbutils \
      nano \
      python-usb \
      wget \
      gnupg2 \
      software-properties-common

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

RUN useradd -d /home/pi -G sudo -m pi

RUN echo "pi ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pi

RUN wget -O - http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo apt-key add -
RUN echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list
RUN apt-get update

WORKDIR /home/pi

USER pi

RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
RUN cd RetroPie-Setup \
    && sudo chmod +x retropie_setup.sh \
    && sudo ./retropie_packages.sh setup basic_install
    
# and Installs RetroPie + optional modules declared in install.sh
COPY --chown=pi install_retropie_addons.sh /tmp/install_retropie_addons.sh
COPY --chown=pi addons.cfg /tmp/addons.cfg
COPY --chown=pi post_install.sh /tmp/post_install.sh

RUN bash /tmp/install_retropie_addons.sh

RUN bash rm -rf /home/pi/RetroPie-Setup/tmp/

# Install USB controller resetting utility
COPY utilities/reset_controller.py /opt/retropie/configs/all/reset_controller.py
COPY utilities/reset_controller.sh /opt/retropie/configs/all/reset_controller.sh

# And install script hooks
COPY utilities/runcommand-onstart.sh /opt/retropie/configs/all/runcommand-onstart.sh 

# Edit this file in your persistent storage to use all or part of the name provided from "lsusb" to reset the controller on each start 
RUN touch /opt/retropie/configs/all/controller_usb_ids && chown pi:pi /opt/retropie/configs/all/controller_usb_ids

RUN bash /tmp/post_install.sh

COPY --chown=pi ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["run"]
