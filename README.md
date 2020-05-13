# Introduction

This is a configurable build container for RetroPie based on [laseryuan's retropie container](https://github.com/laseryuan/docker-apps/tree/master/retropie).
Currently this container targets AMD64 only, and this is meant for a full fledged installation of RetroPie plus the majority of addons/modules into an 
Ubuntu 18.04 environment, including the PCSX2 emulator from the nightly PPA. 

**This will take a very very long time to build, like overnight**

 - Docker repo: https://hub.docker.com/r/hotspoons/retropie-container
 - GitHub repo: https://github.com/hotspoons/retropie-container

# Usage

## Building

To pull and build the image locally using default settings, run the following:

```bash

docker run --rm hotspoons/retropie-container

```


## Customizing

Yes, I know this breaks the core tenet of repeatabile, portable builds for docker images, but you wouldn't be looking here if this was your primary concern :).

To modify what modules/addons are build, clone the git repository:

```bash

cd ~
git clone https://github.com/hotspoons/retropie-container.git

cd retropie-container

```

Modify the "addons.cfg" file to include or exclude modules as desired, found here: https://retropie.org.uk/forum/topic/23317/creating-shell-script-for-installing-everything

Then build and tag the repository locally (in this example, with the tag "retropie-container:0.0.1"):

```bash

docker build --tag retropie-container:0.0.1 .

```

## Running

To run the default image, either execute the following in a shell, or create a shell script and execute it.

Please set the following variables in the script below:

 - **roms_folder** : This should correspond to a path on the host where ROMs are organized by system, for use by RetroPie. 
 - **bios_folder** : This should correspond to a path on the host where BIOS images are stored
 - **config_folder** : This is where persistent storage for all RetroPie configuration is stored on the host system
 - **media_root** : An optional volume to mount in the container; omit this argument if not used in the command. My use case is that all of \
my emulator assets are stored in an NFS share mounted on /media/import/media on the host, then symlinked from a central folder on the mount. \
Using this volume makes resolving the links possible. 
     - In my configuration, the **roms_folder** volume is /media/import/media/emulators/retropie_links/roms on the host system. The 
RetroPie *arcade* folder **retropie_links/roms/arcade** is a symlink to another folder on this volume like so:   
         - **/media/import/media/emulators/retropie_links/roms/arcade -> /media/import/media/emulators/MAME2003_Reference_Set_MAME0.78_ROMs_CHDs_Samples**
 - **container_name** : If using the stock image, leave as is; if you customized your image, use your local container tag 

```bash
#!/bin/bash
roms_folder=/path/to/roms/folder
bios_folder=/path/to/bios/folder
config_folder=/path/to/persistent/config/folder
media_root=/path/to/optional/absolute/mount/for/symlinks
container_name=hotspoons/retropie-container # or retropie-container:0.0.1 if built and tagged locally


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
  $container_name \
  run

  bash


```
