#!/bin/bash
cd /usr/share/foreman-proxy
if [ -z "$(find /var/run/screen/ -name \*.$NAME 2>/dev/null)" ]; then
    screen -d -m -S foreman bash -c 'rackup; exec bash'
    sleep 1
fi
