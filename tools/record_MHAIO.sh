#!/bin/bash

# Copyright 2018 Marc René Schädler
#
# This file is part of the mobile hearing aid prototype project
# The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

PLAYFILE="$1"
DURATION="$2"
RECFILE="$3"

if [ $# -lt 3 ]; then
  echo "Read the source for usage"
  exit 1
fi

if [ ! -e "$PLAYFILE" ]; then
  echo "File '${PLAYFILE}' does not exist!"
  exit 1
fi

echo "Warmup"
mplayer &> /dev/null
jack_rec &> /dev/null

echo "Start playback"
mplayer -ao jack:name=mplayer:noestimate:port=MHA "${PLAYFILE}" &
sleep 2

echo "Start recording"
jack_rec -f "${RECFILE}" -d "${DURATION}" -b 32 mplayer:out_0 mplayer:out_1 MHA:out_1 MHA:out_2



