#!/bin/sh -e

for i in `find etc -type f`; do
 cp /$i $i
done

