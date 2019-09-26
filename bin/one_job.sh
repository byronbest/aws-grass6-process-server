#!/bin/bash

if [ -e rc ] ; then
. rc
fi

cd $HOME

if [ -e rc ] ; then
. rc
fi

export GISRC=$HOME/.grassrc6
#if [ ! -e $GISRC ] ; then
cat > $GISRC <<++eof++
GISDBASE: $GRASSDBASE
LOCATION_NAME: $LOCATION
MAPSET: $MAPSET
MONITOR: cairo7
GRASS_GUI: text
++eof++
#fi

grass64 $GRASSDBASE/$LOCATION/$MAPSET \
2>&1 > $TARGETDIR/grass.log

exit $?
