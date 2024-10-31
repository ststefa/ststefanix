#!/bin/sh

if nc -z localhost 9150 2>/dev/null ; then
    curl --socks5 localhost:9150 http://ifconfig.me
else
    echo "TCP port localhost:9150 unreachable. Make sure tor is running" >&2
    exit 1
fi
