#!/bin/sh

nginx -c '/nginx.conf'

mkdir -p '/run/dump1090'
dump1090 --quiet --net --write-json '/run/dump1090'
