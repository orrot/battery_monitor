pidbattery_monitor=$(pgrep -f battery_monitor.sh)
if [ -z "${pidbattery_monitor}" ]; then
    # off
    echo "1"
else
    # on
    echo "0"
fi
