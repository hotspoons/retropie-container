#!/bin/bash
docker run -it --rm --name=retropie \
  --privileged \
  -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v /run/user/1000:/run/user/1000 \
  -v /media/import/media:/media/import/media \
  -v /dev/input:/dev/input \
  retropie-container:0.0.1 \
  run

  bash
