#!/bin/bash

PLAYFILE="$1"
DURATION="$2"
RECFILE="$3"

if [ $# -lt 3 ];
 then
  echo "Read the source for usage"
  exit 1
fi

if [ ! -e "$PLAYFILE" ]; then
  echo "File '${PLAYFILE}' does not exist!"
  exit 1
fi

echo "Start playback"
mplayer -ao jack:name=mplayer:noestimate:port=system "${PLAYFILE}" &
sleep 1

echo "Start recording"
jack_rec -f "${RECFILE}" -d "${DURATION}" -b 32 mplayer:out_0 mplayer:out_1 system:capture_1 system:capture_2



