#!/bin/sh

set -e

nginx -g 'pid /tmp/nginx.pid;' -c '/nginx.conf'
mkdir -p '/run/dump1090'
/usr/bin/dump1090 --quiet --net --write-json '/run/dump1090'
