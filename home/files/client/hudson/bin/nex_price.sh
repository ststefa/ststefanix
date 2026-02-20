#!/bin/bash
# $1 the order ref to look up

if (( $# != 1 )) ; then
    echo "Show price of trade pair from base to quote." >&2
    echo >&2
    echo "Usage: $0 tarde-pair" >&2
    echo "where:" >&2
    echo "  tarde-pair - Case sensitive to-from price pair, e.g. BTCLTC" >&2
    exit 1
fi

CURL_OPTS="-s -S"
# cloudflare is blocking tor requests
#if nc -z he2 9050 2>/dev/null ; then
if false ; then
    CURL_OPTS="${CURL_OPTS} --socks5 he2:9050"
fi

RESPONSE="$(curl ${CURL_OPTS} https://api.n.exchange/en/api/v1/get_price/${1}/)"
echo " ${RESPONSE}"
