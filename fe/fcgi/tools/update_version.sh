#!/bin/sh -ex

cd `dirname $0`
ruby check_version.rb > ../version.txt 

