#!/bin/bash
# $1 the address for resulting coin to be sent to

if (( $# != 1 )) ; then
    echo "Cancel ShapeShift transaction specified by deposit coin address" >&2
    echo "If there is fund sent to the deposit address, this pending transaction" >&2
    echo "cannot be canceled." >&2
    echo >&2
    echo "Usage: $0 deposit" >&2
    echo "where:" >&2
    echo "  deposit - target coin address created with a transaction" >&2
    exit 1
fi

nc -z localhost 9150 2>/dev/null
if (( $? != 0 )) ; then
    echo "TCP port localhost:9150 unreachable. Make sure tor is running" >&2
    exit 1
fi

curl -s -S --socks5 localhost:9150 -H "Content-Type: application/json" -X POST -d "{\"address\":\"$1\"}" https://shapeshift.io/cancelpending|jq
