#!/bin/bash

source ./addons.cfg


user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"
readonly RP_SETUP_DIR="$home/RetroPie-Setup"

cd $RP_SETUP_DIR

for o in "${opt[@]}"
do
   sudo ./retropie_packages.sh $o depends
   sudo ./retropie_packages.sh $o sources
   sudo ./retropie_packages.sh $o build
   sudo ./retropie_packages.sh $o install
   sudo ./retropie_packages.sh $o configure
done

for d in "${driver[@]}"
do
   sudo ./retropie_packages.sh $d depends
   sudo ./retropie_packages.sh $d sources
   sudo ./retropie_packages.sh $d build
   sudo ./retropie_packages.sh $d install
   sudo ./retropie_packages.sh $d configure
done

for e in "${exp[@]}"
do
   sudo ./retropie_packages.sh $e depends
   sudo ./retropie_packages.sh $e sources
   sudo ./retropie_packages.sh $e build
   sudo ./retropie_packages.sh $e install
   sudo ./retropie_packages.sh $e configure
done


