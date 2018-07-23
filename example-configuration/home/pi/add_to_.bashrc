export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

PATH=$PATH:~/njconnect-1.5:~/openMHA/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/openMHA/lib

# Autostart after 5 seconds
mkdir /tmp/autostart.completed &>/dev/null && echo "Will start JACK and openMHA in 5 seconds (press Ctrl+C to cancel)" && sleep 5 && cd ~/hearingaid-prototype && ./start.sh
