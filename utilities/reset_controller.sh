#!/bin/bash
until pids=$(pidof retroarch)
do
	sleep 1
done

sleep 3	

declare -a controller_names
readarray controller_names < /opt/retropie/configs/all/controller_names

let i=0
while (( ${#controller_names[@]} > i )); do
    controller="${controller_names[i++]}"
    sudo /opt/retropie/configs/all/reset_controller.py "$controller"
    sleep 1
    sudo /opt/retropie/configs/all/reset_controller.py "$controller"

    printf "Attempt to reset $controller\n"
done


