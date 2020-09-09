#!/bin/sh

set -ex

if [ $(id -u) -ne 0 ]; then
  echo "This script must be run under root, aborting"
  exit 1
fi

rules="$(iptables -t mangle --list-rules)"

if [ $? -ne 0 ]; then
    echo "Could not list existing rules, do you have a kernel with MANGLE support?"
    exit 1
fi

existing=`echo -e "$rules" | grep -- "--ttl-set 64" || true`
if [ ! -z "$existing" ]; then
    echo "ttl-set rule already exists, aborting"
    exit 0
fi

echo "Setting iptables rule"
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64 -o "rmnet+"

echo "ALL DONE"
