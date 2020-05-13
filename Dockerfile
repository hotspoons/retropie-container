FROM retropie-base-container:0.0.1

ENV LANG C.UTF-8

WORKDIR /home/pi

USER pi

# and Installs RetroPie + optional modules declared in install.sh
COPY --chown=pi install.sh /tmp/install.sh

RUN bash /tmp/install.sh

COPY --chown=pi ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["run"]
