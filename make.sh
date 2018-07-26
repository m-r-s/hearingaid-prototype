#!/bin/bash

CFLAGS="-Wall -Ofast"

error() {
  echo "$1"
  exit 1
}

# Compile all C code

(cd tools/control && gcc ${CFLAGS} translate.c -o translate) || error "translate"
(cd tools/abhang/src/jack && gcc ${CFLAGS} abhang.c -o abhang -lm -ljack) || error "abhang"
(cd tools/signals && gcc ${CFLAGS} whitenoise.c -o whitenoise -lm -ljack) || error "whitenoise"
(cd tools/signals && gcc ${CFLAGS} sweep.c -o sweep -lm -ljack) || error "sweep"
(cd tools/signals && gcc ${CFLAGS} pinknoise.c -o pinknoise -lm -ljack) || error "pinknoise"

