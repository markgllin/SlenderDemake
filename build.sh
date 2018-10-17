#!/bin/sh

# simple bash script to compile and load program into xvic.
#
# you'll want to copy dasm + xvic (compiled for your machine since 
# I'm on mac) to your root.
#
# can probably add this to .gitignore after

./dasm slender.asm -v3 -oslender.prg


./xvic.app/Contents/MacOS/xvic slender.prg