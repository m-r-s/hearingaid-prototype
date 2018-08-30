#!/bin/bash

# Copyright 2018 Marc René Schädler
#
# This file is part of the mobile hearing aid prototype project
# The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

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

