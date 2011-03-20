#!/bin/sh

cd `dirname $0`
cd ..

if [ "x$1" = "xstart" ]; then
  touch maintenance
  touch handler.rb
elif [ "x$1" = "xstop" ]; then
  rm -f maintenance
  touch handler.rb
else
  echo "Usage: $0 [start|stop]"
  exit 1
fi
