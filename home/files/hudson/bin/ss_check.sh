#!/bin/bash
# $1 the deposit address to look up
if (( $# != 1 )) ; then
    echo "Query status of ShapeShift transaction to see if funds arrived" >&2
    echo >&2
    echo "Usage: $0 target_addr" >&2
    echo "where:" >&2
    echo "  target_addr - target withdrawal address created with a shapeshift transaction" >&2
    exit 1
fi

nc -z localhost 9150 2>/dev/null
if (( $? != 0 )) ; then
    echo "TCP port localhost:9150 unreachable. Make sure tor is running" >&2
    exit 1
fi

curl -s -S --socks5 localhost:9150 https://shapeshift.io/txStat/$1 |jq
