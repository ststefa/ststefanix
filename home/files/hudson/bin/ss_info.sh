#!/bin/bash
# $1: rate pair, eg ltc_btc

if (( $# != 1 )) ; then
    echo "Show market info for given coin pair" >&2
    echo >&2
    echo "Usage: $0 coinpair" >&2
    echo "where:" >&2
    echo "  coinpair   - coin change pair, e.g. ltc_btc, btc_ltc, ..." >&2
    exit 1
fi

curl -s -S --socks5 localhost:9150 https://shapeshift.io/marketinfo/$1 |jq
