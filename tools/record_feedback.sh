#!/bin/bash

echo "start white noise"
(cd feedback/tools && ./whitenoise) 2>&1 &
sleep 0.1
jack_connect whitenoise:output_1 system:playback_2
jack_connect whitenoise:output_2 system:playback_1

echo "record feedback"
jack_rec -f "/tmp/feedback.wav" -d 10 -b 32 whitenoise:output_1 whitenoise:output_2 system:output_1 system:output_2

echo "stop white noise"
killall whitenoise -9 &> /dev/null
