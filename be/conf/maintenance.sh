#!/bin/sh

set -e

if [ "x$1" = "xstart" ]; then
  perl -i -p -e '\
s@^(iface.*static|address|netmask)@#$1@; \
s@^#(iface.*dhcp)@$1@; ' /etc/network/interfaces
elif [ "x$1" = "xstop" ]; then
  perl -i -p -e '\
s@^#(iface.*static|address|netmask)@$1@; \
s@^(iface.*dhcp)@#$1@; ' /etc/network/interfaces
else
  echo "Usage: $0 [start|stop]"
  exit 1
fi

/etc/init.d/networking restart
