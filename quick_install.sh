#!/bin/bash

container_tag=retropie-container:0.0.1
artifacts_path=~/.config/retropie-container
container_name=retropie
nvidia_info=$(nvidia-smi)

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
by running the command \"$artifacts_path/run-retropie.sh\". You may provide additional arguments to the \"docker run\" command by providing \
the value in quotes after a \"-c\" argument, for example:\n\nrun-retropie.sh -c \"-v /path/to/volume:/path/to/volume --net host \
-v /run/udev/control:/run/udev/control \ --gpus all\" \n\n"



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

# In case the container was previously created or a step failed, stop it and remove it
docker container stop  $container_name
docker container rm $container_name

docker build --tag retropie-container:0.0.1 .
docker run -it -d --name=retropie  retropie-container:0.0.1 
docker cp $container_name:/home/pi/retropie-cfg.tar.gz $artifacts_path/retropie-cfg.tar.gz && tar --skip-old-files -xvf $artifacts_path/retropie-cfg.tar.gz -C $artifacts_path/configs 
docker cp $container_name:/home/pi/retropie-roms.tar.gz $artifacts_path/retropie-roms.tar.gz && tar --skip-old-files -xvf $artifacts_path/retropie-roms.tar.gz -C $artifacts_path/roms
docker container stop  $container_name
docker container rm $container_name

echo "" > $artifacts_path/run-retropie.sh
echo "#!/bin/bash" >> $artifacts_path/run-retropie.sh
echo "" >> $artifacts_path/run-retropie.sh
echo "help()" >> $artifacts_path/run-retropie.sh
echo "{" >> $artifacts_path/run-retropie.sh
echo "   echo \"\"" >> $artifacts_path/run-retropie.sh
echo "   echo \"Usage: $0 -h -c *custom arguments for docker run command\"" >> $artifacts_path/run-retropie.sh
echo "   echo -e \"\\t-h Print this help\"" >> $artifacts_path/run-retropie.sh
echo "   echo -e \"\\t-c any custom arguments you wish to provide to the docker run command, such as additional volume mounts\"" >> $artifacts_path/run-retropie.sh
echo "   exit 1" >> $artifacts_path/run-retropie.sh
echo "}" >> $artifacts_path/run-retropie.sh
echo "" >> $artifacts_path/run-retropie.sh
echo "while getopts \":hc:\" opt" >> $artifacts_path/run-retropie.sh
echo "do" >> $artifacts_path/run-retropie.sh
echo "   case "\$opt" in" >> $artifacts_path/run-retropie.sh
echo "      h ) help; exit 0 ;;" >> $artifacts_path/run-retropie.sh
echo "      c ) custom_args=\"\$OPTARG\" ;;" >> $artifacts_path/run-retropie.sh
echo "      :) echo \"missing argument for option -$OPTARG\"; exit 1 ;;" >> $artifacts_path/run-retropie.sh
echo "      \?) echo \"didnt' get that\"; exit 1 ;;" >> $artifacts_path/run-retropie.sh
echo "   esac" >> $artifacts_path/run-retropie.sh
echo "done" >> $artifacts_path/run-retropie.sh
echo "" >> $artifacts_path/run-retropie.sh
echo "roms_folder=$artifacts_path/roms" >> $artifacts_path/run-retropie.sh
echo "bios_folder=$artifacts_path/bios" >> $artifacts_path/run-retropie.sh
echo "config_folder=$artifacts_path/configs" >> $artifacts_path/run-retropie.sh
echo "container_name=$container_tag" >> $artifacts_path/run-retropie.sh
echo "container_short_name=$container_name" >> $artifacts_path/run-retropie.sh
echo ""  >> $artifacts_path/run-retropie.sh
echo "docker container stop \$container_short_name"  >> $artifacts_path/run-retropie.sh
echo "docker container rm \$container_short_name"  >> $artifacts_path/run-retropie.sh
echo ""  >> $artifacts_path/run-retropie.sh
echo "docker run -it --rm --name=retropie \\" >> $artifacts_path/run-retropie.sh
echo "  --privileged \\" >> $artifacts_path/run-retropie.sh
if grep -q "GPU Memory" <<< $nvidia_info; then
	echo "  --gpus all \\"  >> $artifacts_path/run-retropie.sh
fi
echo "  -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix \\" >> $artifacts_path/run-retropie.sh
echo "  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \\" >> $artifacts_path/run-retropie.sh
echo "  --net host \\" >> $artifacts_path/run-retropie.sh
echo "  -v /run/udev/control:/run/udev/control \\" >> $artifacts_path/run-retropie.sh
echo "  -v /run/user/1000:/run/user/1000 \\" >> $artifacts_path/run-retropie.sh
echo "  -v /dev/input:/dev/input \\" >> $artifacts_path/run-retropie.sh
echo "  -v \$roms_folder:/home/pi/RetroPie/roms \\" >> $artifacts_path/run-retropie.sh
echo "  -v \$bios_folder:/home/pi/RetroPie/BIOS \\" >> $artifacts_path/run-retropie.sh
echo "  -v \$config_folder:/opt/retropie/configs \\" >> $artifacts_path/run-retropie.sh
echo "  \$custom_args \\" >> $artifacts_path/run-retropie.sh
echo "   \$container_name \\" >> $artifacts_path/run-retropie.sh
echo "  run" >> $artifacts_path/run-retropie.sh
echo " " >> $artifacts_path/run-retropie.sh


echo   
echo   
echo   
echo "If there were no errors, installation is now complete. You can add additional ROMs and BIOS images to the folders $artifacts_path/roms, BIOS and $artifacts_path/bios.\
 And you may run this RetroPie container by executing \"$artifacts_path/run-retropie.sh\" in a Desktop (e.g. X session)"
