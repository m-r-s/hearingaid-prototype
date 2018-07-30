#!/bin/bash

DIR=$(cd "$( dirname "$0" )" && pwd)

DURATION="$1"
echo "killall abhang"
killall abhang -9 &> /dev/null
sleep 0.5

echo "start pink noise"
(cd "${DIR}/tools/signals" && ./pinknoise) 2>&1 &
sleep 0.5

jack_connect pinknoise:output_1 system:playback_2
jack_connect pinknoise:output_2 system:playback_1

echo "record feedback"
jack_rec -f "/tmp/feedback.wav" -d "$DURATION" -b 32 pinknoise:output_1 pinknoise:output_2 system:capture_1 system:capture_2

echo "stop pink noise"
killall pinknoise -9 &> /dev/null

echo "calculate feedback path"
(cd "${DIR}/tools/" && taskset -c 0 nice ./update_abhang_configuration.m)

echo "start static feedback cancelation"
(cd "${DIR}/tools/abhang/src/jack" && taskset -c 2 ./abhang) 2>&1 &

sleep 0.5
echo "connect abhang"
jack_connect system:capture_1 abhang:input_1
jack_connect system:capture_2 abhang:input_2
jack_connect MHA:out_1 abhang:input_3
jack_connect MHA:out_2 abhang:input_4
jack_connect abhang:output_1 MHA:in_1
jack_connect abhang:output_2 MHA:in_2

