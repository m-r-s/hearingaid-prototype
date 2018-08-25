#!/bin/bash

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

(cd tools && octave-cli --eval "userinterface")
