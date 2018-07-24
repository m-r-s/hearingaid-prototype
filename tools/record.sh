#!/bin/bash

DURATION=$1
PAUSE=$2
TEMPFILE="/dev/shm/recording-$$.wav"
TARGETDIR="${HOME}/recordings/"

mkdir -p "$TARGETDIR"

while true; do
  jack_rec -f "$TEMPFILE" -d"$DURATION" -b32 abhang:output_1 abhang:output_2
  TARGETFILE="${TARGETDIR}/"$(date --iso-8601=seconds)".wav"
  mv "$TEMPFILE" "$TARGETFILE"
  sleep "$PAUSE"
done

