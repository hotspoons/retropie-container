#!/bin/bash

container_tag=retropie-container:0.0.1
artifacts_path=~/.config/retropie-container
container_name=retropie

echo 
printf "This is a no-frills, low resistence installation script for hotspoons/retropie-container. This assumes you have already installed docker on your \
host and have it configured to pull from the main docker hub. This also assumes that you will be running the docker container as the current user; \
you will be storing persistent artifacts for this container in the folder $artifacts_path; and you are okay with the container being registered \
locally as \"$container_tag\". This script is dumb and may break things, delete your files, and insult your mother. You have been warned." 
echo
echo
printf "If you wish to customize which packages are installed and have not yet made your choices, enter \"N\" below and add or remove selections from \
addons.cfg, then re-run this script" 
echo
echo
printf "Would you like to continue? Your ROMs will need to be copied to $artifacts_path/roms, BIOS to $artifacts_path/bios, \
and your configuration will be stored in $artifacts_path/configs. After installation, you can run this container from a Desktop Linux session \
by running the command \"$artifacts_path/run-retropie.sh\".\n\n"



read -p $"Enter \"Y\" to proceed`echo $'\n> '`"  -n 1 -r
echo       
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

mkdir -p $artifacts_path/bios
mkdir -p $artifacts_path/roms
mkdir -p $artifacts_path/configs
touch $artifacts_path/run-retropie.sh && chmod +x $artifacts_path/run-retropie.sh 

docker build --tag retropie-container:0.0.1 .
docker run -it -d --name=retropie  retropie-container:0.0.1 
docker cp $container_tag:/home/pi/retropie-cfg.tar.gz $artifacts_path/retropie-cfg.tar.gz && tar -xvf retropie-cfg.tar.gz -C $artifacts_path/configs 
docker cp $container_tag:/home/pi/retropie-roms.tar.gz $artifacts_path/retropie-roms.tar.gz && tar -xvf retropie-roms.tar.gz -C $artifacts_path/roms
docker container stop retropie

echo "" > $artifacts_path/run-retropie.sh
echo "#!/bin/bash" >> $artifacts_path/run-retropie.sh
echo "roms_folder=$artifacts_path/roms" >> $artifacts_path/run-retropie.sh
echo "bios_folder=$artifacts_path/bios" >> $artifacts_path/run-retropie.sh
echo "config_folder=$artifacts_path/configs" >> $artifacts_path/run-retropie.sh
echo "container_name=$container_tag" >> $artifacts_path/run-retropie.sh
echo ""  >> $artifacts_path/run-retropie.sh
echo "docker run -it --rm --name=retropie \" >> $artifacts_path/run-retropie.sh
echo "  --privileged \" >> $artifacts_path/run-retropie.sh
echo "  -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix \" >> $artifacts_path/run-retropie.sh
echo "  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \" >> $artifacts_path/run-retropie.sh
echo "  -v /run/user/1000:/run/user/1000 \" >> $artifacts_path/run-retropie.sh
echo "  -v /dev/input:/dev/input \" >> $artifacts_path/run-retropie.sh
echo "  -v \$roms_folder:/home/pi/RetroPie/roms \" >> $artifacts_path/run-retropie.sh
echo "  -v \$bios_folder:/home/pi/RetroPie/BIOS \" >> $artifacts_path/run-retropie.sh
echo "  -v \$config_folder:/opt/retropie/configs \" >> $artifacts_path/run-retropie.sh
echo "  \$container_name \" >> $artifacts_path/run-retropie.sh
echo "  run" >> $artifacts_path/run-retropie.sh
echo " " >> $artifacts_path/run-retropie.sh
echo " bash" >> $artifacts_path/run-retropie.sh

echo   
echo   
echo   
echo "If there were no errors, installation is now complete. You can add additional ROMs and BIOS images to the folders $artifacts_path/roms, BIOS and $artifacts_path/bios.\
 And you may run this RetroPie container by executing \"$artifacts_path/run-retropie.sh\" in a Desktop (e.g. X session)"
