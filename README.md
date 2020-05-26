# Introduction

This is a configurable build container for RetroPie based on [laseryuan's retropie container](https://github.com/laseryuan/docker-apps/tree/master/retropie).
Currently this container targets AMD64 (including Nvidia proprietary graphics if necessary), and ARM32v7.  This is meant for a full fledged installation of 
RetroPie plus the majority of addons/modules into an Ubuntu 18.04 environment, including wine and the PCSX2 emulator from the nightly PPA for AMD64. 

**This will take a very very long time to build, like overnight**

 - Docker repo: https://hub.docker.com/r/hotspoons/retropie-container
 - GitHub repo: https://github.com/hotspoons/retropie-container

# Prerequisites

 - Your host system should have some sort of *nix OS with an X server running, or sufficient polyfill in Windows
 - You must have docker installed and running on your host system
 - The current user must have access to manage docker (e.g. member of "docker" group)
 - If you use the proprietary Nvidia graphics drivers, you will need to install and configure nvidia-docker (see these instructions: https://github.com/NVIDIA/nvidia-docker)
 - ROMs and BIOSes will help with making this setup useful 


# Quick install, configure, and run

Please look at the notes and warnings section at the bottom for details regarding how to get input working in RetroArch. 

## Quick Install

Execute the following in a shell on your docker host to install and run this container:

```bash
# or "curl -o quick_install.sh https://github.com/hotspoons/retropie-container/raw/features/base/quick_install.sh"
wget https://github.com/hotspoons/retropie-container/raw/features/base/quick_install.sh 

# This will test for prerequisites before attempting to fetch and configure the container. It will warn for Nvidia docker as well if it detects 
# the nvidia proprietary driver.
sh quick_install.sh

```

## Configure

See the "Notes and Warnings" section at the bottom for more information, but you will need to place the USB IDs of each controller you wish
to use in this container, one per line, in the file ~/.config/retropie-container/configs/all/controller_usb_ids. To get the USB IDs, run the
"lsusb" command on your host, then place the ID listed for each device into the file listed below. For example:

```bash
rich@rich-dell:~$ lsusb 
...
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 002: ID 045e:02dd Microsoft Corp. Xbox One Controller (Firmware 2015)
...
```

I would place the following contents in the "controller_usb_ids" file for my Xbox One conntroller:

```bash
045e:02dd
```

## Run

```bash

# You may provide additional custom arguments to the docker command using the "-c" flag, e.g. '-c " -v /media/import/media:/media/import/media"'
~/.config/retropie-container/run-retropie.sh

```

# Manual installation and configuration

If you wish to build this image locally and/or edit which RetroPie packages are installed, you will need to clone the GitHub repository,
check out the correct branch, edit your module selection, then use the "custom_install.sh" script, or manually configure the persistent
storage and scripts per the instructions below.

## Target architectures

 - If using the basic AMD64 build:
     - Use the "features/amd64-nvidia" branch for manual builds/customization (e.g. cd ~ && git clone https://github.com/hotspoons/retropie-container && cd retropie-container && git checkout features/amd64-nvidia)
     - Or use "amd64-nvidia" docker tag (e.g. docker pull hotspoons/retropie-container:amd64-nvidia)
 - If using the NVIDIA proprietary driver:
     - Install and configure nvidia-docker for your system, see https://github.com/NVIDIA/nvidia-docker for details
     - Use the "features/amd64-nvidia" branch for manual builds/customization (e.g. cd ~ && git clone https://github.com/hotspoons/retropie-container && cd retropie-container && git checkout features/amd64-nvidia)
     - Or use "amd64-nvidia" docker tag (e.g. docker pull hotspoons/retropie-container:amd64-nvidia)
 - If using the ARM32v7 build:
     - Use the "features/arm32v7" branch for manual builds/customization (e.g. cd ~ && git clone https://github.com/hotspoons/retropie-container && cd retropie-container && git checkout features/arm32v7)
     - Or use "arm32v7" docker tag (e.g. docker pull hotspoons/retropie-container:arm32v7)

## Customizing RetroPie addons

To modify which modules/addons are built,modify the "addons.cfg" file to include or exclude modules as desired, found here: https://retropie.org.uk/forum/topic/23317/creating-shell-script-for-installing-everything

## Building and installing after customization

If you are okay with the default locations for persistent artifacts and scripts, run the "custom_install.sh" script from the correct git branch (
features/amd64-nvidia or features/arm32v7) like so, presuming you are currently in the cloned repository's local directory:

```bash
sh ./custom_install.sh
# And input "Y" when prompted
```

## Persistence and Artifacts

If the default setup does not suit your needs, you will need to extract the RetroPie configuration for all modules that were built, as well as assets 
that were stored in the *RetroPie/roms* folder for ports and other non-core/base runtimes from the image after building is completed. As part of the 
build process, these are archived in the image under */home/pi/retropie-cfg.tar.gz* and */home/pi/retropie-roms.tar.gz* respectively.

To copy these assets out and extract them, perform the following (this assumes you want to copy and extract these to the folder ~/retropie-assets/; adjust these steps for your enviornment):

```bash

# Make sure you have the container running
docker run -it -d --name=retropie hotspoons/retropie-container # or  retropie-container:local if built and tagged locally 

mkdir -p ~/retropie-assets/configs && mkdir ~/retropie-assets/roms && cd ~/retropie-assets
docker cp retropie:/home/pi/retropie-cfg.tar.gz $artifacts_path/retropie-cfg.tar.gz && tar --skip-old-files -xvf ~/retropie-assets/retropie-cfg.tar.gz -C ~/retropie-assets/configs 
docker cp retropie:/home/pi/retropie-roms.tar.gz $artifacts_path/retropie-roms.tar.gz && tar --skip-old-files -xvf ~/retropie-assets/retropie-roms.tar.gz -C ~/retropie-assets/roms


```

When configuring RetroPie to run below, use the structure extracted from retropie-cfg.tar.gz, e.g ~/retropie-assets/configs as the **config_folder** variable. 
Merge the contents of ~/retropie-assets/roms with your roms folder, used below as **roms_folder**.


## Configuration

Please set the following variables in the script below:

 - **roms_folder** : This should correspond to a path on the host where ROMs are organized by system, for use by RetroPie. 
 - **bios_folder** : This should correspond to a path on the host where BIOS images are stored
 - **config_folder** : This is where persistent storage for all RetroPie configuration is stored on the host system
 - **container_name** : If using the stock image, leave as is; if you customized your image, use your local container tag 

## Running

To run the default image, either execute the following in a shell, or create a shell script and execute it.

```bash
#!/bin/bash
roms_folder=/path/to/roms/folder
bios_folder=/path/to/bios/folder
config_folder=/path/to/persistent/config/folder
container_name=hotspoons/retropie-container # or retropie-container:local if built and tagged locally
container_short_name=retropie
nvargs=

if grep -q "GPU Memory" <<< $(nvidia-smi); then
   nvargs="--gpus all"
fi

docker container stop $container_short_name
docker container rm $container_short_name

docker run -it --rm --name=retropie \
  --privileged \
  $nvargs \
  -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  --net host \
  -v /run/udev/control:/run/udev/control \
  -v /run/user/1000:/run/user/1000 \
  -v /dev/input:/dev/input \
  -v $roms_folder:/home/pi/RetroPie/roms \
  -v $bios_folder:/home/pi/RetroPie/BIOS \
  -v $config_folder:/opt/retropie/configs \
  $custom_args \
   $container_name \
  run


```

# Notes and warnings

Because of bugs somewhere between RetroPie and Docker's forwarding of udev events, the udev driver for RetroArch does not work unless:
 - You launch docker with the argument " --net host"
 - You mount /run/udev/control folder as a volume in the container with the argument "-v /run/udev/control:/run/udev/control"
 - You *unplug* and *replug* the controller every time you launch a game in a libretro emulator via RetroArch (a work around for this follows)
 - See https://stackoverflow.com/questions/49687378/how-to-get-hosts-udev-events-from-a-docker-container for more info
 
I created a combination of bash and python scripts as part of this container's source code repo that will soft-reset all configured 
USB controllers (see below) every time that RetroArch is started. This effectively works around the issue above, but may have unintended
consequences, so beware.  
 
If you use the quick install script, a work-around is installed for you that requires you to only add the USB IDs, 1 per line, of 
each controller you wish to use to the file **$$config_folder**$/all/controller_usb_ids. For example, my controller_usb_ids file contains 
1 line with the contents "045e:02dd" that I found by running "lsusb" on the host and finding the line that corresponds with "Microsoft Corp. 
Xbox One Controller (Firmware 2015)". 

If you are using an off-the-shelf image from docker hub, you will need to manually install the work-arounds into the persistent configuration 
storage folder. Copy the files "utilites/reset_controller.py", "utilites/reset_controller.sh", and "utilites/runcommand-onstart.sh" to the folder 
**$config_folder**/all/ (/opt/retropie/configs/all in the container) from this source code repository and make all 3 of those files executable
(e.g. chmod +x **$config_folder**/all/reset_controller.py && chmod +x **$config_folder**/all/reset_controller.sh && chmod +x 
**$config_folder**/all/runcommand-onstart.sh). Then create a file named controller_usb_ids in the folder **$$config_folder**$/all/ and add the
USB IDs of each of the controllers you wish to use, one per line, per the instructions above.
