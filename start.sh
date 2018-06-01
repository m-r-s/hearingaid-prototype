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

echo "killall whitenoise"
killall whitenoise -9 &> /dev/null

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

echo "start white noise"
(cd tools/feedback/tools && ./whitenoise) 2>&1 &
sleep 0.1
jack_connect whitenoise:output_1 system:playback_2
jack_connect whitenoise:output_2 system:playback_1

echo "record feedback"
jack_rec -f "/tmp/feedback.wav" -d 10 -b 32 whitenoise:output_1 whitenoise:output_2 system:capture_1 system:capture_2

echo "stop white noise"
killall whitenoise -9 &> /dev/null

echo "calculate feedback path"
(cd tools/feedback/tools && nice ./update_configuration.m)

echo "start static feedback cancelation"
(cd tools/feedback/src/jack && taskset -c 2 ./abhang) 2>&1 &
sleep 1

echo "start thresholdnoise"
(cd tools/impairment && taskset -c 2 ./thresholdnoise) 2>&1 &
sleep 1

echo "start mha"
taskset -c 3 mha --interface=$MHAIP --port=$MHAPORT "?read:${MHACONFIG}" 2>&1 | sed 's/^/[MHA] /' &
sleep 1

# Connections
echo "Wireing..."
jack_connect system:capture_1 abhang:input_1
jack_connect system:capture_2 abhang:input_2
jack_connect MHA:out_1 abhang:input_3
jack_connect MHA:out_2 abhang:input_4
jack_connect thresholdnoise:output_1 abhang:input_3
jack_connect thresholdnoise:output_2 abhang:input_4
jack_connect abhang:output_1 MHA:in_1
jack_connect abhang:output_2 MHA:in_2
jack_connect MHA:out_1 system:playback_2
jack_connect MHA:out_2 system:playback_1
jack_connect thresholdnoise:output_1 system:playback_2
jack_connect thresholdnoise:output_2 system:playback_1
echo "RUNNING!"
