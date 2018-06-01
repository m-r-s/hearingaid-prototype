#!/bin/bash

CFLAGS="-Wall -Ofast"

error() {
  echo "$1"
  exit 1
}

# Compile all C code

(cd tools/feedback/src/jack && gcc ${CFLAGS} abhang.c -o abhang -lm -ljack) || error "abhang"
(cd tools/feedback/tools && gcc ${CFLAGS} whitenoise.c -o whitenoise -lm -ljack) || error "whitenoise"
(cd tools/impairment && gcc ${CFLAGS} thresholdnoise.c -o thresholdnoise -lm -ljack) || error "thresholdnoise"

