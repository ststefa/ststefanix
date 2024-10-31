#!/bin/bash
# $1 the address for resulting coin to be sent to
# $2 rate pair, e.g. ltc_btc

if (( $# != 2 )) ; then
    echo "Create ShapeShift transaction to convert coins." >&2
    echo "Target coin will be sent to withdrawal address (an address you own)" >&2
    echo "Source coin must be sent to deposit address (created with transaction)" >&2
    echo >&2
    echo "Usage: $0 coinpair withdrawal" >&2
    echo "where:" >&2
    echo "  coinpair   - coin change pair, e.g. ltc_btc, btc_ltc, ..." >&2
    echo "  withdrawal - target coin address to send funds to" >&2
    exit 1
fi

nc -z localhost 9150 2>/dev/null
if (( $? != 0 )) ; then
    echo "TCP port localhost:9150 unreachable. Make sure tor is running" >&2
    exit 1
fi

curl -s -S --socks5 localhost:9150 -H "Content-Type: application/json" -X POST -d "{\"withdrawal\":\"$2\", \"pair\":\"$1\"}" https://shapeshift.io/shift|jq
