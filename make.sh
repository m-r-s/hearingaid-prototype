#!/bin/bash

CFLAGS="-Wall -Ofast"

error() {
  echo "$1"
  exit 1
}

# Compile all C code

# static feedback cancellation as JACK plugin
(cd tools/feedback/src/jack && gcc ${CFLAGS} abhang.c -o abhang -lm -ljack) || error "abhang"
(cd tools/feedback/tools && gcc ${CFLAGS} whitenoise.c -o whitenoise -lm -ljack) || error "whitenoise"

