#!/bin/bash

#Modules you wish to install as part of your setup

declare -a opt=("basilisk" "dgen" "dosbox" "hatari" "linapple" "openmsx" "osmose" "ppsspp" "reicast" "scummvm" "simcoupe" "stella" "stratagus" "vice" "zesarux" "lr-beetle-lynx" "lr-beetle-psx" "lr-beetle-vb" "lr-beetle-wswan" "lr-bluemsx" "lr-bsnes" "lr-fbalpha2012" "lr-fmsx" "lr-freeintv" "lr-gw" "lr-mame2010" "lr-mrboom" "lr-nxengine" "lr-o2em" "lr-parallel-n64" "lr-ppsspp" "lr-prboom" "lr-snes9x" "lr-tgbdual" "lr-tyrquake" "alephone" "cannonball" "darkplaces-quake" "dxx-rebirth" "eduke32" "kodi" "lincity-ng" "love-0.10.2" "love" "micropolis" "openpht" "openttd" "opentyrian" "sdlpop" "smw" "solarus" "supertux" "tyrquake" "uqm" "wolf4sdl" "scraper" "skyscraper")
declare -a driver=("ps3controller" "sixaxis""steamcontroller" "xboxdrv" "xpad")
declare -a exp=("dolphin" "dosbox-sdl2" "fs-uae" "minivmac" "px68k" "quasi88" "residualvm" "sdltrs" "ti99sim" "xm7" "lr-4do" "lr-81" "lr-beetle-pcfx" "lr-beetle-saturn" "lr-desmume2015" "lr-desmume" "lr-dinothawr" "lr-dolphin" "lr-dosbox" "lr-flycast" "lr-freechaf" "lr-hatari" "lr-kronos" "lr-mame2003-plus" "lr-mame2015" "lr-mame2016" "lr-mame" "lr-mess2016" "lr-mess" "lr-muppen64plux-next" "lr-np2kai" "lr-pokemini" "lr-puae" "lr-px68k" "lr-quasi88" "lr-redream" "lr-scummvm" "lr-superflappybirds" "lr-vice" "lr-virtualjaguar" "lr-x1" "lr-yabause" "abuse" "bombermaaan" "cdogs-sdl" "cgenius" "digger" "gemrb" "ioquake3" "jumpnbump" "mysticmine" "openblok" "splitwolf" "srb2" "yquake2" "attractmode" "emulationstation-dev" "launchingimages" "mehstation" "mobilegamepad" "pegasus-fe" "retropie-manager" "skyscraper" "virtualgamepad")
#"pcsx2" 


# main retropie setup

git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup && sudo chmod +x retropie_setup.sh \
    && sudo ./retropie_packages.sh setup basic_install

# install modules declared above

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



# installing RetroPie-joystick-selection tool

user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"
readonly RP_SETUP_DIR="$home/RetroPie-Setup"
readonly JS_SCRIPTMODULE_FULL="$RP_SETUP_DIR/scriptmodules/supplementary/joystick-selection.sh"
readonly JS_SCRIPTMODULE_URL="https://raw.githubusercontent.com/meleu/RetroPie-joystick-selection/master/js-scriptmodule.sh"
readonly JS_SCRIPTMODULE="$(basename "${JS_SCRIPTMODULE_FULL%.*}")"

if [[ ! -d "$RP_SETUP_DIR" ]]; then
    echo "ERROR: \"$RP_SETUP_DIR\" directory not found!" >&2
    echo "Looks like you don't have RetroPie-Setup scripts installed in the usual place. Aborting..." >&2
    exit 1
fi

curl "$JS_SCRIPTMODULE_URL" -o "$JS_SCRIPTMODULE_FULL"

if [[ ! -s "$JS_SCRIPTMODULE_FULL" ]]; then
    echo "Failed to install. Aborting..." >&2
    exit 1
fi

sudo __platform=$__platform "$RP_SETUP_DIR/retropie_packages.sh" "$JS_SCRIPTMODULE"

tar -czvf $home/retropie-cfg.tar.gz /opt/retropie/configs
