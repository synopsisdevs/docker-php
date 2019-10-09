#!/bin/bash
set -m

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &

./wait

fg %1