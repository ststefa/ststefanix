#!/bin/bash
# $1 the order ref to look up

if (( $# != 2 )) ; then
    echo "Create n.exchange LTC-to-BTC exchange order" >&2
    echo >&2
    echo "Usage: $0 ltc-amount btc-target" >&2
    echo "where:" >&2
    echo "  ltc-amount - The amount of LTC to send and exchange" >&2
    echo "  btc-target - The BTC adress to which the exchanged amount is sent" >&2
    exit 1
fi

CURL_OPTS="-s -S"
# cloudflare is blocking tor requests
#if nc -z he2 9050 2>/dev/null ; then
if false ; then
    CURL_OPTS="${CURL_OPTS} --socks5 he2:9050"
fi
RESPONSE="$(curl ${CURL_OPTS} \
    --request POST \
    --header "Content-Type: application/json" \
    --data-binary "{
        \"amount_quote\": ${1},
        \"is_default_rule\": false,
        \"pair\": {
            \"name\": \"BTCLTC\"
        },
        \"withdraw_address\": {
            \"address\": \"${2}\"
    }
}" \
'https://api.n.exchange/en/api/v1/orders/')"
echo "Full response "
echo "${RESPONSE}" | jq
echo "Created order $(echo "${RESPONSE}" | jq .unique_reference)"
echo "Send $(echo "${RESPONSE}" | jq .amount_quote) LTC to $(echo "${RESPONSE}" | jq .deposit_address.address)"
echo "Receive $(echo "${RESPONSE}" | jq .amount_base) BTC at $(echo "${RESPONSE}" | jq .withdraw_address.address)"
echo "Send LTC until $(echo "${RESPONSE}" | jq .payment_deadline) at latest"
