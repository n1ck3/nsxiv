#!/usr/bin/env bash

make clean

rm config.h &> /dev/null

make
if [[ "$?" > 0 ]] ; then
    echo
    echo "!!! Make went wrong. :( Exiting..."
    exit 1
fi

sudo make clean install
