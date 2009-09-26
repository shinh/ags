#!/bin/sh -e

cd conf
for i in `find etc -type f`; do
 cp /$i $i
done

