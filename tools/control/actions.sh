#!/bin/bash

text2speech() {
  echo "text2speech: '$1'"
  local FILE=$(mktemp -p /dev/shm)
  flite -t "$1" "$FILE"
  # aplay -D 'jack' "$FILE"
  mhacmd "mha.transducers.mhachain.addsndfile.filename = $FILE"
  sleep 0.1
  rm "$FILE"
}

mhacmd() {
  echo "mhacmd: '$1'"
  echo "$1" | nc -w 1 127.0.0.1 33337 | grep -m1 -E "\(MHA:[^)]+\)"
}

action_poweroff() {
  text2speech "Power off!"
  sleep 2
  sudo poweroff;
}

action_nosound() {
  text2speech "Output off!"
  mhacmd "mha.transducers.mhachain.altplugs.select = (none)"
}

action_no_amplification() {
  text2speech "No amplification!"
  mhacmd "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:fittings/nogain.cfg"
}

action_linear_amplification() {
  text2speech "Linear amplification!"
  mhacmd "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:fittings/linear40.cfg"
}

action_compressive_amplification1() {
  text2speech "Compressive amplification 1!"
  mhacmd "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:fittings/plack2004.cfg"
}

action_compressive_amplification2() {
  text2speech "Compressive amplification 2!"
  mhacmd "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc?read:fittings/plack2004low.cfg"
}

action_noise_off() {
  text2speech "Noise off!"
  jack_disconnect thresholdnoise:output_1 system:playback_2
  jack_disconnect thresholdnoise:output_2 system:playback_1
  jack_disconnect thresholdnoise:output_1 abhang:input_3
  jack_disconnect thresholdnoise:output_2 abhang:input_4
}

action_noise_on() {
  text2speech "Noise on!"
  jack_connect thresholdnoise:output_1 abhang:input_3
  jack_connect thresholdnoise:output_2 abhang:input_4
  jack_connect thresholdnoise:output_1 system:playback_2
  jack_connect thresholdnoise:output_2 system:playback_1
}

action_amplification_off() {
  text2speech "Amplification off!"
  mhacmd "mha.transducers.mhachain.altplugs.select = identity"
}

action_amplification_on() {
  text2speech "Amplification on!"
  mhacmd "mha.transducers.mhachain.altplugs.select = dynamiccompression"
}

action_feedback() {
  action_noise_off
  sleep 1
  text2speech "Measure feedback!"
  init_feedbackcancellation.sh "$1"
}

while true; do
  if [ -e "/dev/input/js0" ]; then
    text2speech "Bluetooth connected!"
    cat /dev/input/js0 | stdbuf -i0 -o0 -e0 ./translate | while read line; do
      case "${line: -8}" in
      "01000100")
        echo "A"
        action_no_amplification
      ;;
      "01000101")
        echo "B"
        action_linear_amplification
      ;;
      "01000103")
        echo "X"
        action_compressive_amplification1
      ;;
      "01000104")
        echo "Y"
        action_compressive_amplification2
      ;;
      "0100010b")
        echo "Start"
        action_poweroff
      ;;
      "0100010a")
        echo "Select"
        action_nosound
      ;;
      "01000107")
        echo "RT"
        action_feedback 5
      ;;
      "01000106")
        echo "LT"
        action_feedback 2
      ;;
      "01800201")
        echo "Up"
        action_amplification_on
      ;;
      "ff7f0201")
        echo "Down"
        action_amplification_off
      ;;
      "01800200")
        echo "Left"
        action_noise_off
        ;;
      "ff7f0200")
        echo "Right"
        action_noise_on
      ;;
#    *)
#      echo "UNKOWN: ${line: -8}"
#    ;;
      esac
    done
    text2speech "Bluetooth disconnected!"
  else
    sleep 1
  fi
done
