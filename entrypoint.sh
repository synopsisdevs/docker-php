#!/bin/bash

chmod 0644 -R /etc/cron.d/
cron
touch /var/log/cron.log
tail -f /var/log/cron.log
