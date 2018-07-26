#!/bin/bash

while true; do
  if [ -e "/dev/input/js0" ]; then
    cat /dev/input/js0 | stdbuf -i0 -o0 -e0 ./translate | while read line; do
      case "${line: -8}" in
      "01000100")
        echo "A"
        sudo poweroff
      ;;
      "01000101")
        echo "B"
      ;;
      "01000103")
        echo "X"
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
