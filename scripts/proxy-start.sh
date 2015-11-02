#!/usr/bin/env bash

set -exo pipefail

if [ -e /opt/src/smart-proxy ]; then
    PROXY_DIR=/opt/src/smart-proxy
elif [ -e /root/proxy-src/smart-proxy ]; then
    PROXY_DIR=/root/proxy-src/smart-proxy
fi

cd $PROXY_DIR
bundle install
bundle exec rackup
