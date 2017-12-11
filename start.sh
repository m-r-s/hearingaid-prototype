#!/bin/bash

# Simple sound configuration
SOUNDDEVICE=audioinjectorpi
SOUNDSTREAM=0
SOUNDCHANNELS=1,2
SAMPLERATE=48000
FRAGSIZE=64
NPERIODS=2

# MHA config
MHACONFIG="openMHA.cfg"
MHAIP=127.0.0.1
MHAPORT=33337

echo ""
echo "OPENMHA EXAMPLE FOR HEARING AID PROTOTYPE"
echo ""

echo "kill mha"
killall mha -9 &> /dev/null

echo "kill jackd"
killall jackd -9 &> /dev/null
sleep 1

echo "start jackd"
taskset -c 2 jackd -P70 -p16 -t2000 -d alsa -d hw:$SOUNDDEVICE,$SOUNDSTREAM -p $FRAGSIZE -r $SAMPLERATE -n $NPERIODS -s 2>&1 | sed 's/^/[JACKD] /' &
sleep 2

echo "start mha"
taskset -c 2 mha --interface=$MHAIP --port=$MHAPORT "?read:${MHACONFIG}" 2>&1 | sed 's/^/[MHA] /' &
sleep 1

echo "RUNNING!"
