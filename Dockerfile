FROM retropie-base-container:0.0.1

ENV LANG C.UTF-8

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
RUN bash /tmp/post_install.sh

COPY --chown=pi ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["run"]
