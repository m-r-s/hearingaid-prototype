#!/bin/bash

# Copyright 2018 Marc René Schädler
#
# This file is part of the mobile hearing aid prototype project
# The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

# Simple sound configuration
SOUNDDEVICE=audioinjectorpi
SOUNDSTREAM=0
SOUNDCHANNELS=1,2
SAMPLERATE=48000
FRAGSIZE=48
NPERIODS=2

# MHA config
MHACONFIG="openMHA.cfg"
MHAIP=127.0.0.1
MHAPORT=33337

echo ""
echo "OPENMHA EXAMPLE FOR HEARING AID PROTOTYPE"
echo ""

echo "killall thresholdnoise"
killall thresholdnoise -9 &> /dev/null

echo "killall pink noise"
killall pinknoise -9 &> /dev/null

echo "killall abhang"
killall abhang -9 &> /dev/null

echo "killall mha"
killall mha -9 &> /dev/null

echo "killall jackd"
killall jackd -9 &> /dev/null

echo "killall commander.sh"
killall commander.sh -9 &> /dev/null

echo "killall octave-cli"
killall octave-cli -9 &> /dev/null

echo "killall tcpserver"
killall tcpserver -9 &> /dev/null


sleep 1

echo "start jackd"
taskset -c 1 jackd --realtime -d alsa -d hw:$SOUNDDEVICE,$SOUNDSTREAM -p $FRAGSIZE -r $SAMPLERATE -n $NPERIODS -s 2>&1 | sed 's/^/[JACKD] /' &

sleep 2

echo "start threshold noise"
(cd tools/signals && taskset -c 2 ./thresholdnoise) | sed 's/^/[THRESHOLDNOISE] /' &

echo "start mha"
taskset -c 3 mha --interface=$MHAIP --port=$MHAPORT "?read:${MHACONFIG}" 2>&1 | sed 's/^/[MHA] /' &

echo "start commander"
[ -e "commandqueue" ] || mkfifo commandqueue
./commander.sh | sed 's/^/[COMMANDER] /' &

sleep 1

echo "connect mha"
jack_connect MHA:out_1 system:playback_2
jack_connect MHA:out_2 system:playback_1

echo "initial commands"
echo feedback 3 > commandqueue

echo "start network command server"
tcpserver -H -R 0.0.0.0 33338 ./netcommand.sh | sed 's/^/[NETCMD] /' &

(cd tools && octave-cli --eval "userinterface")
