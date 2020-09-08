#!/bin/sh

set -ex

echo "Looking for default route"

routes=$(ip route)

if [[ "$routes" == *wlan* ]]; then
    echo "You should disable WIFI first"
    exit 1
fi
echo "All good, WIFI is not found"

default_route=$(echo -e "$routes" | grep rmnet | sed -E 's/.* (rmnet[a-z0-9_]*) .+/\1/')

echo "Found route $default_route"


if [[ -z "$default_route" ]]; then
    echo "Route is not found, aborting"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
  echo "This script must be run under root, aborting"
  exit 1
fi

iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64 -o "$default_route"

echo "ALL DONE"
