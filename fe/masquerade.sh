#!/bin/sh

case "$1" in
  start)
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o xenbr1 -j MASQUERADE
    ;;
  stop)
    echo 0 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -D POSTROUTING -o xenbr1 -j MASQUERADE
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 2
esac
exit $?
