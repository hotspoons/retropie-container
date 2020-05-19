#!/bin/bash
sleep 10 # change this as necessary to ensure enough time is available for the emulator to start
declare -a controller_names
readarray controller_names < /opt/retropie/configs/all/controller_names

let i=0
while (( ${#controller_names[@]} > i )); do
    controller="${controller_names[i++]}"
    sudo reset_controller.py "$controller"
    sleep 1
    sudo reset_controller.py "$controller"
    printf "Attempt to reset $controller\n"
done


