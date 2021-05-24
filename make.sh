#!/bin/bash

# Copyright 2018 Marc René Schädler
#
# This file is part of the mobile hearing aid prototype project
# The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

CFLAGS="-Wall -Ofast -march=native"

error() {
  echo "$1"
  exit 1
}

# Compile all C code

(cd tools/abhang/src/jack && gcc ${CFLAGS} abhang.c -o abhang -lm -ljack) || error "abhang"
(cd tools/signals && gcc ${CFLAGS} whitenoise.c -o whitenoise -lm -ljack) || error "whitenoise"
(cd tools/signals && gcc ${CFLAGS} sweep.c -o sweep -lm -ljack) || error "sweep"
(cd tools/signals && gcc ${CFLAGS} pinknoise.c -o pinknoise -lm -ljack) || error "pinknoise"
(cd tools/signals && gcc ${CFLAGS} thresholdnoise.c -o thresholdnoise -lm -ljack) || error "thresholdnoise"

