#!/bin/sh -e

cd conf
for i in `find . -type f`; do
 cp /$i $i
done

