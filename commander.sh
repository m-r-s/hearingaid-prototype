#!/bin/bash

# Copyright 2018 Marc René Schädler
#
# This file is part of the mobile hearing aid prototype project
# The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.


DIR=$(cd "$( dirname "$0" )" && pwd)
TOOLSDIR="${DIR}/tools"

mhacontrol() {
  echo "$@" | nc -w 1 127.0.0.1 33337 | grep -m1 -E "\(MHA:[^)]+\)" &>/dev/null
}

mhaplay() {
  local FILE="$1"
  local LEVELMODE="$2"
  local LEVEL="$3"
  local LOOP="$4"
  local RETVAL=1
  mhacontrol "mha.transducers.mhachain.playback.filename = "
  mhacontrol "mha.transducers.mhachain.playback.levelmode = ${LEVELMODE}"
  mhacontrol "mha.transducers.mhachain.playback.level = ${LEVEL}"
  mhacontrol "mha.transducers.mhachain.playback.loop = ${LOOP}"
  mhacontrol "mha.transducers.mhachain.playback.filename = $FILE" && RETVAL=0
  sleep 0.1
  rm "$FILE"
  return "$RETVAL"
}

text2speech() {
  local RETVAL=1
  local FILE=$(mktemp -p /dev/shm)
  flite -t "$1" "$FILE"
  mhaplay "$FILE" "rms" "70" "no"
}

feedback() {
  local DURATION="$1"
  killall abhang -9 &> /dev/null
  (cd "${TOOLSDIR}/signals" && ./pinknoise) 2>&1 &
  sleep 0.5
  jack_connect pinknoise:output_1 system:playback_2
  jack_connect pinknoise:output_2 system:playback_1
  jack_rec -f "/dev/shm/feedback.wav" -d "$DURATION" -b 32 pinknoise:output_1 pinknoise:output_2 system:capture_1 system:capture_2
  killall pinknoise -9 &> /dev/null
  (cd "${TOOLSDIR}" && taskset -c 0 nice ./update_abhang_configuration.m)
  rm "/dev/shm/feedback.wav"
  (cd "${TOOLSDIR}/abhang/src/jack" && taskset -c 2 ./abhang) 2>&1 &
  sleep 1
  jack_connect system:capture_1 abhang:input_1
  jack_connect system:capture_2 abhang:input_2
  jack_connect MHA:out_1 abhang:input_3
  jack_connect MHA:out_2 abhang:input_4
  jack_connect abhang:output_1 MHA:in_1
  jack_connect abhang:output_2 MHA:in_2
}

thresholdnoise() {
  local STATUS="$1"
  case "$STATUS" in
    on)
      jack_connect thresholdnoise:output_1 abhang:input_3
      jack_connect thresholdnoise:output_2 abhang:input_4
      jack_connect thresholdnoise:output_1 system:playback_2
      jack_connect thresholdnoise:output_2 system:playback_1
    ;;
    off)
      jack_disconnect thresholdnoise:output_1 system:playback_2
      jack_disconnect thresholdnoise:output_2 system:playback_1
      jack_disconnect thresholdnoise:output_1 abhang:input_3
      jack_disconnect thresholdnoise:output_2 abhang:input_4
    ;;
  esac
}

record() {
  local DURATION=$1
  local TEMPFILE="/dev/shm/recording-$$.wav"
  local TARGETFILE="${HOME}/recordings/"$(date --iso-8601=seconds)".wav"
  jack_rec -f "$TEMPFILE" -d"$DURATION" -b32 abhang:output_1 abhang:output_2
  mv "$TEMPFILE" "$TARGETFILE"
}

while true ; do
  while read line; do
    COMMAND="${line%% *}"
    ARGUMENTS="${line#${COMMAND} }"
    echo "COMMAND '$COMMAND'"
    echo "ARGUMENTS '$ARGUMENTS'"
    case "$COMMAND" in
    "feedback")
      feedback ${ARGUMENTS[@]}
    ;;
    "text2speech")
      text2speech "${ARGUMENTS[@]}"
    ;;
    "mhacontrol")
      mhacontrol ${ARGUMENTS[@]}
    ;;
    "mhaplay")
      mhaplay ${ARGUMENTS[@]}
    ;;
    "thresholdnoise")
      thresholdnoise ${ARGUMENTS[@]}
    ;;
    "record")
      record ${ARGUMENTS[@]}
    ;;
    esac
  done < commandqueue
done
