#!/bin/bash

artifacts_path=~/.config/retropie-container
container_name="retropie"
nvidia_info=$(nvidia-smi)
is_nvidia=$(nvidia-smi | grep -w "GPU Memory")
is_amd64=$(uname -m | grep -i -w "x86_64\|amd64\|x64")
is_arm=$(uname -m | grep -i -w "aarch64\|armv7l\|arm64\|arm64v8\|armv8b\|armv8l")
is_git_installed=$(which git)
is_docker_installed=$(docker ps | grep "CONTAINER ID")
retropie_container_repo="https://github.com/hotspoons/retropie-container.git"
installer_branch="features/base"
docker_repo="hotspoons/retropie-container"
nvidia_tag="amd64-nvidia"
arm_tag="arm32v7"
tmp_folder="/tmp"
tag=""

if [ -z "$is_amd64" ] && [ -z "$is_arm" ] 
then
    printf "Either an AMD64 or ARMv7 or newer compatible host is required to run and install this container"
    exit 1
else
    if [ -z "$is_amd64" ] 
    then
        tag=$arm_tag
    else
    	tag=$nvidia_tag
    fi
fi

if [ -z "$is_git_installed" ] 
then
    printf "\"git\" must be installed to install this container and runtime. Please install git on your host OS and try again."
    exit 1
fi

if [ -z "$is_docker_installed" ] 
then
    printf "\"docker\" must be installed, running, and accessible to the current user (e.g. current user must be a member \
of the \"docker\" group). Please check your docker setup and try this again."
    exit 1
fi

if [ -z "$is_nvidia" ] 
then
   printf "It appears you are running the proprietary Nvidia graphics driver on your host. Before you run this container, ensure that \
you have installed and configured nvidia docker (see this: https://github.com/NVIDIA/nvidia-docker for instructions), or else \
the container may not start"
fi

cd $tmp_folder
rm -rf rpc
git clone $retropie_container_repo rpc
cd rpc
git checkout $installer_branch


printf "Starting installation process in 5 seconds. Your ROMs will need to be copied to $artifacts_path/roms, BIOS to $artifacts_path/bios, \
and your configuration will be stored in $artifacts_path/configs. After installation, you can run this container from a Desktop Linux session \
by running the command \"$artifacts_path/run-retropie.sh\". You may provide additional arguments to the \"docker run\" command by providing \
the value in quotes after a \"-c\" argument, for example:\n\nrun-retropie.sh -c \"-v /path/to/volume:/path/to/volume " \n\n"

sleep 5
mkdir -p $artifacts_path/bios
mkdir -p $artifacts_path/roms
mkdir -p $artifacts_path/configs
touch $artifacts_path/run-retropie.sh && chmod +x $artifacts_path/run-retropie.sh 

# In case the container was previously created or a step failed, stop it and remove it
docker container stop  $container_name
docker container rm $container_name
docker pull $docker_repo:$tag

docker run -it -d --name=$container_name $docker_repo:$tag
docker cp $container_name:/home/pi/retropie-cfg.tar.gz $artifacts_path/retropie-cfg.tar.gz && tar --skip-old-files -xvf $artifacts_path/retropie-cfg.tar.gz -C $artifacts_path/configs 
docker cp $container_name:/home/pi/retropie-roms.tar.gz $artifacts_path/retropie-roms.tar.gz && tar --skip-old-files -xvf $artifacts_path/retropie-roms.tar.gz -C $artifacts_path/roms
docker container stop  $container_name
docker container rm $container_name

echo "" > $artifacts_path/run-retropie.sh
echo "#!/bin/bash" >> $artifacts_path/run-retropie.sh
echo "" >> $artifacts_path/run-retropie.sh
echo "help\(\)" >> $artifacts_path/run-retropie.sh
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
echo "      h \) help; exit 0 ;;" >> $artifacts_path/run-retropie.sh
echo "      c \) custom_args=\"\$OPTARG\" ;;" >> $artifacts_path/run-retropie.sh
echo "      :\) echo \"missing argument for option -$OPTARG\"; exit 1 ;;" >> $artifacts_path/run-retropie.sh
echo "      \?\) echo \"didnt' get that\"; exit 1 ;;" >> $artifacts_path/run-retropie.sh
echo "   esac" >> $artifacts_path/run-retropie.sh
echo "done" >> $artifacts_path/run-retropie.sh
echo "" >> $artifacts_path/run-retropie.sh
echo "roms_folder=$artifacts_path/roms" >> $artifacts_path/run-retropie.sh
echo "bios_folder=$artifacts_path/bios" >> $artifacts_path/run-retropie.sh
echo "config_folder=$artifacts_path/configs" >> $artifacts_path/run-retropie.sh
echo "container_name=$docker_repo:$tag" >> $artifacts_path/run-retropie.sh
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
echo "  -v /dev/bus/usb:/dev/bus/usb \\" >> $artifacts_path/run-retropie.sh
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
