#!/bin/bash

# sudo nano ${HOME}/.config/systemd/user/battery_monitor.service
# sudo nano /etc/systemd/system/battery_monitor.service

# systemctl --user enable --now battery_monitor

truncate -s 0 ~/Battery/batstat
echo ' --- ' >> ~/Battery/batstat

interval="5s"
batcheck_file=~/Battery/batcheck
status_filename=~/Battery/.battery_status
truncate -s 0 $status_filename
echo "true" >> $status_filename

# Create the battery history folder
mkdir -p ~/Battery/history

start_updated_date=$(upower -i `upower -e | grep 'BAT'` | grep 'updated:' | grep -o -E '[0-9]+ [a-Z]{3} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} (AM|PM)')
start_updated_date_epoch=$(date -d "$start_updated_date" "+%s")
start_current_energy=$(upower -i `upower -e | grep 'BAT'` | grep 'energy:' | grep -o -E '[0-9]+,[0-9]+')
start_current_energy=${start_current_energy/,/.}
interval_updated_date_epoch="$start_updated_date_epoch"

while grep -q 'true' ~/Battery/.battery_status; do

  ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
  if [ "$ac_adapter" = "off" ]; then

    # Get all the battery calculated stats by upower. 
    # Fecha epoch,current,max value, rate
    updated_date=$(upower -i `upower -e | grep 'BAT'` | grep 'updated:' | grep -o -E '[0-9]+ [a-Z]{3} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} (AM|PM)')
    updated_date_epoch=$(date -d "$updated_date" "+%s")
    current_energy=$(upower -i `upower -e | grep 'BAT'` | grep 'energy:' | grep -o -E '[0-9]+,[0-9]+')
    current_energy=${current_energy/,/.}
    full_design_energy=$(upower -i `upower -e | grep 'BAT'` | grep 'energy-full-design:' | grep -o -E '[0-9]+,[0-9]+')
    full_design_energy=${full_design_energy/,/.}
    energy_rate=$(upower -i `upower -e | grep 'BAT'` | grep 'energy-rate:' | grep -o -E '[0-9]+,[0-9]+')
    energy_rate=${energy_rate/,/.}

    session_seconds=$(echo "scale=2; $updated_date_epoch-$start_updated_date_epoch" | bc)
    consumed=$(echo "scale=2; $start_current_energy-$current_energy" | bc)

    if [ "$consumed" != "0" ]; then 
      session_full_estimated=$(echo "scale=2; ($session_seconds*$full_design_energy)/$consumed" | bc)
      session_empty_estimated=$(echo "scale=2; ($session_seconds*$current_energy)/$consumed" | bc)

      current_estimate_hours=$(echo "scale=2; $current_energy/$energy_rate" | bc)
      full_design_estimate_hours=$(echo "scale=2; $full_design_energy/$energy_rate" | bc)
      
      avg_estimate_hours=$(echo "scale=2; $session_empty_estimated/3600" | bc)
      avg_full_design_estimate_hours=$(echo "scale=2; $session_full_estimated/3600" | bc);
      avg_estimate_hours_int=$(echo "scale=0; $session_empty_estimated/3600" | bc)

      # Just consider estimations between 0 and 15
      if [ "$avg_estimate_hours_int" -gt 0 ] && [ "$avg_estimate_hours_int" -lt 30 ]; then
        truncate -s 0 ~/Battery/batstat
        echo $avg_estimate_hours | awk '{printf("%.1f h\n",$1)}' >> ~/Battery/batstat
        echo $avg_full_design_estimate_hours | awk '{printf("%.1f h\n",$1)}' >> ~/Battery/batstat
      fi
      
    fi
    # Debug
    # echo "$ac_adapter"
    # echo "session_full_estimated: ${session_full_estimated},session_empty_estimated: ${session_empty_estimated}"
    # echo "current_estimate_seconds: ${current_estimate_seconds},full_design_estimate_seconds: ${full_design_estimate_seconds}"
    # echo "${consumed},${session_seconds},${session_seconds},${avg_full_design_estimate_hours},${avg_estimate_hours}"
    
    
    # Debug with file
    # echo "${updated_date},${updated_date_epoch},${start_current_energy},${current_energy},${full_design_energy},${energy_rate},${current_estimate_hours},${full_design_estimate_hours},${consumed},${avg_full_design_estimate_hours},${avg_estimate_hours}" >> ~/Battery/batmonitor.csv
    
    elapsed_time_till_last_report=$(echo "scale=0; $updated_date_epoch-$interval_updated_date_epoch" | bc)
    if [ "$elapsed_time_till_last_report" -gt 1800 ]; then 
      echo "${updated_date},${updated_date_epoch},${start_current_energy},${interval_updated_date_epoch},${current_energy},${full_design_energy},${energy_rate},${current_estimate_hours},${full_design_estimate_hours},${consumed},${avg_full_design_estimate_hours},${avg_estimate_hours}" >> ~/Battery/history/monitor.csv
      interval_updated_date_epoch=${updated_date_epoch}
    fi
    truncate -s 0 $batcheck_file
    echo "0" >> $batcheck_file
  else 
    start_updated_date=$(upower -i `upower -e | grep 'BAT'` | grep 'updated:' | grep -o -E '[0-9]+ [a-Z]{3} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} (AM|PM)')
    start_updated_date_epoch=$(date -d "$start_updated_date" "+%s")
    start_current_energy=$(upower -i `upower -e | grep 'BAT'` | grep 'energy:' | grep -o -E '[0-9]+,[0-9]+')
    start_current_energy=${start_current_energy/,/.}
    truncate -s 0 ~/Battery/batstat
    echo ' --- ' >> ~/Battery/batstat
    truncate -s 0 $batcheck_file
    echo "1" >> $batcheck_file
  fi
  sleep $interval
done  
