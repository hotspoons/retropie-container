#!/bin/bash

source /tmp/addons.cfg


user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"
readonly RP_SETUP_DIR="$home/RetroPie-Setup"

echo "Starting module installations..."

cd $RP_SETUP_DIR

for o in "${opt[@]}"
do
   sudo __platform=rpi3 ./retropie_packages.sh $o depends
   sudo __platform=rpi3 ./retropie_packages.sh $o sources
   sudo __platform=rpi3 ./retropie_packages.sh $o build
   sudo __platform=rpi3 ./retropie_packages.sh $o install
   sudo __platform=rpi3 ./retropie_packages.sh $o configure
done

for d in "${driver[@]}"
do
   sudo __platform=rpi3 ./retropie_packages.sh $d depends
   sudo __platform=rpi3 ./retropie_packages.sh $d sources
   sudo __platform=rpi3 ./retropie_packages.sh $d build
   sudo __platform=rpi3 ./retropie_packages.sh $d install
   sudo __platform=rpi3 ./retropie_packages.sh $d configure
done

for e in "${exp[@]}"
do
   sudo __platform=rpi3 ./retropie_packages.sh $e depends
   sudo __platform=rpi3 ./retropie_packages.sh $e sources
   sudo __platform=rpi3 ./retropie_packages.sh $e build
   sudo __platform=rpi3 ./retropie_packages.sh $e install
   sudo __platform=rpi3 ./retropie_packages.sh $e configure
done


