#!/bin/bash
roms_folder=/media/import/media/emulators/retropie_links/roms
bios_folder=/media/import/media/emulators/retropie_links/BIOS
config_folder=~/.retropie-container/opt-retropie-config
media_root=/media/import/media

docker run -it --rm --name=retropie \
  --privileged \
  -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v /run/user/1000:/run/user/1000 \
  -v $media_root:$media_root \
  -v /dev/input:/dev/input \
  -v $roms_folder:/home/pi/RetroPie/roms \
  -v $bios_folder:/home/pi/RetroPie/BIOS \
  -v $config_folder:/opt/retropie/configs \
  retropie-container:0.0.1 \
  run

  bash
