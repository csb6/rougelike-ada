#!/usr/bin/env sh

cd third_party/AdaCurses
./configure
make
cd ../..
gprbuild
