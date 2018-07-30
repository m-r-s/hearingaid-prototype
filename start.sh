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

echo "killall actions.sh"
killall actions.sh -9 &> /dev/null

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

sleep 1

echo "start jackd"
taskset -c 1 jackd --realtime -d alsa -d hw:$SOUNDDEVICE,$SOUNDSTREAM -p $FRAGSIZE -r $SAMPLERATE -n $NPERIODS -s 2>&1 | sed 's/^/[JACKD] /' &
sleep 2

echo "start threshold noise"
(cd tools/signals && ./thresholdnoise) 2>&1 &

echo "start mha"
taskset -c 3 mha --interface=$MHAIP --port=$MHAPORT "?read:${MHACONFIG}" 2>&1 | sed 's/^/[MHA] /' &

echo "inital feedback measurement"
./init_feedbackcancellation.sh 5

echo "connect mha"
jack_connect MHA:out_1 system:playback_2
jack_connect MHA:out_2 system:playback_1

echo "start bluetooth control"
(cd tools/control && taskset -c 0 ./actions.sh) 2>&1 &

echo "RUNNING!"
