#!/bin/bash

function text2speech () {
  echo "text2speech: '$1'"
  local FILE=$(mktemp -p /dev/shm)
  flite -t "$1" "$FILE"
  # aplay -D 'jack' "$FILE"
  mhacmd "mha.transducers.mhachain.addsndfile.filename = $FILE"
  sleep 0.1
  rm "$FILE"
}

function mhacmd {
  echo "mhacmd: '$1'"
  echo "$1" | nc 127.0.0.1 33337 | grep -m1 -E "\(MHA:[^)]+\)" | grep success
}


while true; do
  if [ -e "/dev/input/js0" ]; then
    text2speech "Bluetooth connected!"
    cat /dev/input/js0 | stdbuf -i0 -o0 -e0 ./translate | while read line; do
      case "${line: -8}" in
      "01000100")
        echo "A"
        text2speech "Output off"
        mhacmd "mha.transducers.mhachain.altplugs.select = (none)"
      ;;
      "01000101")
        echo "B"
        text2speech "Off"
        mhacmd "mha.transducers.mhachain.altplugs.select = identity"
      ;;
      "01000103")
        echo "X"
        text2speech "On"
        mhacmd "mha.transducers.mhachain.altplugs.select = dynamiccompression"
      ;;
      "01000104")
        echo "Y"
      ;;
      "0100010b")
        echo "Start"
      ;;
      "0100010a")
        echo "Select"
      ;;
      "01000107")
        echo "RT"
      ;;
      "01000106")
        echo "LT"
      ;;
      "01800201")
        echo "Up"
      ;;
      "ff7f0201")
        echo "Down"
      ;;
      "01800200")
        echo "Left"
      ;;
      "ff7f0200")
        echo "Right"
      ;;
#    *)
#      echo "UNKOWN: ${line: -8}"
#    ;;
      esac
    done
  else
    sleep 1
  fi
done
