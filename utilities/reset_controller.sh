#!/bin/bash
until pids=$(pidof retroarch)
do
	sleep 1
done

sleep 3	

declare -a controller_usb_ids
readarray controller_usb_ids < /opt/retropie/configs/all/controller_usb_ids

let i=0
while (( ${#controller_usb_ids[@]} > i )); do
    controller="${controller_usb_ids[i++]}"
    sudo /opt/retropie/configs/all/reset_controller.py "$controller"
    sleep 1
    sudo /opt/retropie/configs/all/reset_controller.py "$controller"

    printf "Attempt to reset $controller\n"
done


