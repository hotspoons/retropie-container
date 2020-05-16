# Introduction

This is a configurable build container for RetroPie based on [laseryuan's retropie container](https://github.com/laseryuan/docker-apps/tree/master/retropie).
Currently this container targets AMD64 only, and this is meant for a full fledged installation of RetroPie plus the majority of addons/modules into an 
Ubuntu 18.04 environment, including the PCSX2 emulator from the nightly PPA. 

**This will take a very very long time to build, like overnight**

 - Docker repo: https://hub.docker.com/r/hotspoons/retropie-container
 - GitHub repo: https://github.com/hotspoons/retropie-container

# Prerequisites

 - Your host system must be an AMD64-based system (will gladly accept help with making this run on RPi! Would need to drop PCSX2 and wine though)
 - Your host system should have some sort of *nix OS with an X server running, or sufficient polyfill in Windows
 - If using the NVIDIA proprietary driver:
     - Install and configure nvidia-docker for your system, see https://github.com/NVIDIA/nvidia-docker for details
     - Clone the GitHub repo, e.g. cd ~ && git clone https://github.com/hotspoons/retropie-container rpc && cd rpc
     - Swtich to the "features/nvidia-support" branch, e.g. git checkout features/nvidia-support
     - Follow the quick or manual build processes below
     - A better solution will follow
 - You must have docker installed and running on your host system
 - The current user must have access to manage docker (e.g. member of "docker" group)
 - ROMs and BIOSes will help with making this setup useful

# Quick install + run

Please look at the notes and warnings section at the bottom for details regarding how to get input working in RetroArch. 

Execute the following in a shell on your docker host to install and run this container:

## Install

```bash

cd ~
git clone https://github.com/hotspoons/retropie-container rpc
cd rpc
# If you were to customize the modules that are installed, you would do it here by editing "addons.cfg", then continue with the next step
chmod +x quick_install.sh
./quick_install.sh
# And now you will wait for several hours for the build process to complete

```

## Run

```bash

~/.config/retropie-container/run-retropie.sh

```

# Manual installation and configuration

If the default choices provided by the quick install script aren't suitable for your needs or you are afraid to edit the script, 
keep reading.

## Building the default configuration

To pull and build the image locally using default settings (which includes almost everything available in RetroPie, plus PCSX2 and Wine), 
run the following, then skip the next section:

```bash

docker run --rm hotspoons/retropie-container

```


## Customizing

Yes, I know this breaks the core tenet of repeatabile, portable builds for docker images, but you wouldn't be looking here if this was your primary concern :).

To modify which modules/addons are built, clone the git repository:

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

## Persistence and Artifacts

You will need to extract the RetroPie configuration for all modules that were built, as well as assets that were stored in the *RetroPie/roms* folder for
ports and other non-core/base runtimes from the image after building is completed. As part of the build process, these are archived in the image under 
*/home/pi/retropie-cfg.tar.gz* and */home/pi/retropie-roms.tar.gz* respectively.

To copy these assets out and extract them, perform the following (this assumes you want to copy and extract these to the folder ~/retropie-assets/; adjust these steps for your enviornment):

```bash

# Make sure you have the container running
docker run -it -d --name=retropie hotspoons/retropie-container # or  retropie-container:0.0.1 if built and tagged locally 

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
container_name=hotspoons/retropie-container # or retropie-container:0.0.1 if built and tagged locally
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
 - You *unplug* and *replug* the controller every time you launch a game in a libretro emulator via RetroArch
 - See https://stackoverflow.com/questions/49687378/how-to-get-hosts-udev-events-from-a-docker-container for more info
 
A work-around is switching to the "linuxraw" Joypad driver (and losing the automatic bindings provided by Retropie, unfortunately) by:
 - navigating to Retropie -> Retroarch -> Settings -> Drivers -> Joypad and selecting "linuxraw"
 - while still in Retroarch, navigate to Settings -> Configuration -> Save Configuration on Exit (set to ON)
 - Exit Retroarch
 - Open Retroarch again, navigate to Settings -> Configuration -> Save Configuration on Exit (set to ON)
 - Navigate to Settings -> Input -> Port 1 Binds
 - Make sure your controller is listed under "Device Index"
 - Open "Bind All" and setup your controller bindings.
 - Exit Retroarch
 
