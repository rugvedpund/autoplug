#!/bin/bash

echo "Monitoring GPU Utilization and Turning on/off Smart Plug..."
while true; do
    gputemp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    gpuutil=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    plugstatus=$(smartthings devices:status ff91e22e-219c-4ba2-924f-1f7c8c9ecef4 -j | jq -r ".components.main.switch.switch.value")
    timestamp=$(date +%r)
    printf "$timestamp | GPU Util: $gpuutil %%, Plug Status: $plugstatus, GPU Temp: $gputemp \r"  
    sleep 5
    # if [ $gputemp -gt 40 ] && [[ $plugstatus == "off" ]]; then
    if [ $gpuutil -gt 10 ] && [[ $plugstatus == "off" ]]; then
        printf "\n$timestamp | Turning on plug...\n"
        smartthings devices:commands ff91e22e-219c-4ba2-924f-1f7c8c9ecef4 switch:on >> /dev/null
    # elif [ $gputemp -lt 40 ] && [[ $plugstatus == "on" ]]; then
    elif [ $gpuutil -lt 10 ] && [[ $plugstatus == "on" ]]; then
        printf "\n$timestamp | Turning off plug...\n"
        smartthings devices:commands ff91e22e-219c-4ba2-924f-1f7c8c9ecef4 switch:off >> /dev/null
    fi

done
